//
//  ViewController.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-02-28.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var toDoItems: Results<Item>? //Auto updates
    
    var alert : UIAlertController?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - View Did Load Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
            
        title = selectedCategory?.name
        
        guard let colourHex = selectedCategory?.backgroundColour else {fatalError()}

        updateNavBar(withHexCode: colourHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")} //Ok if in viewDidAppear
        guard let navBarColour = UIColor(hexString: colourHexCode) else {fatalError()}
        
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        searchBar.barTintColor = navBarColour
    }

    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (toDoItems?.count ?? 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
       
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none //Ternary operator
            if let backColour = UIColor(hexString:selectedCategory!.backgroundColour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(toDoItems!.count)) {
                    cell.backgroundColor = backColour
                    cell.textLabel?.textColor = ContrastColorOf(backColour, returnFlat: true)
            }
        }
        else {
            cell.textLabel?.text = "No Items" //No Items label not working with swipe cell deletion -> see Q&A on Lecture 269
            cell.accessoryType = .none
        }
        
        return cell
    }

    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done //Toggle boolean in the context object
                }
            } catch {
                print("Error saving done status")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Add new item via alert
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        alert?.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            alertTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        
        //Using Extension
        alert?.addActions(actions: [
            UIAlertAction(title: "Cancel", style: .default, handler: nil),
            UIAlertAction(title: "Add Item", style: .default) { (action) in
                
                if let currentCategory = self.selectedCategory {
                    do {
                         try self.realm.write {
                            let newListItem = Item()
                            newListItem.title = (self.alert?.textFields?[0].text)!
                            newListItem.dateCreated = Date()
                            currentCategory.items.append(newListItem)
                        }
                    } catch {
                        print("Error saving \(error)")
                    }
                }
                self.tableView.reloadData()
            }
            
            ], preferredChoice: "Add Item")
        
        alert?.actions[1].isEnabled = false
        
        present(alert!, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    override func deleteRowData(at indexPath: IndexPath) {
        if let deleteItem = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(deleteItem)
                }
            } catch {
                print("Error deleting \(error)")
            }
        }
    }
    
}

//MARK: - Search Bar Methods Extension

extension ToDoListViewController: UISearchBarDelegate {
    
    //When the search button is clicked in the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text! != "" {
            toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            loadItems()
            
            //Remove the keyboard and stop typing in searchbar (I actually hate this. The alternative is a touch on the table taking out the bar when search is active)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}


//MARK: - UIAlertController Extension
extension UIAlertController {
    func addActions(actions: [UIAlertAction], preferredChoice: String? = nil) {
        
        for action in actions {
            self.addAction(action)
            
            if let preferredChoice = preferredChoice, preferredChoice == action.title {
                self.preferredAction = action
            }
        }
    }
}


//MARK: - Alert Functionality Extension

extension ToDoListViewController {
    
    //Disable the Add Item button when no text entered
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[1].isEnabled = sender.text!.count > 0
    }
}
