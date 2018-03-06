//
//  ViewController.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-02-28.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    var itemArray = [ListItem]() //itemArray is outside context but the ListItem objects are in the context. It is then an array of references to the NSManagedObjects
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }

    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (itemArray.count == 0 ? 1 : itemArray.count) //Allow "No Items" to show up
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
       
        if itemArray.count > 0 {
            let item = itemArray[indexPath.row] //Readability
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none //Ternary operator
        }
        else {
            cell.textLabel?.text = "No Items"
            cell.accessoryType = .none
        }
        
        return cell
    }

    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        context.delete(itemArray[indexPath.row]) //Delete the object in the context
//        itemArray.remove(at: indexPath.row) //Remove the reference to the deleted object
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done //Toggle boolean in the context object
       
        saveItems()
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
                let newListItem = ListItem(context: self.context) //Object created in Context
                newListItem.title = self.alert?.textFields?[0].text
                newListItem.done = false
                newListItem.parentCategory = self.selectedCategory
                self.itemArray.append(newListItem)
                self.saveItems()
            }
            ], preferredChoice: "Add Item")
        
        alert?.actions[1].isEnabled = false
        
        present(alert!, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<ListItem> = ListItem.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }
        else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request) //Returns array of specified objects
        } catch {
           print("Error fetching from context \(error)")
        }
        tableView.reloadData()
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


//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    //When the search button is clicked in the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text! != "" {
            
            let request : NSFetchRequest<ListItem> = ListItem.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request, predicate: predicate)
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


//MARK: - Alert Functionality Extension

extension ToDoListViewController {
    
    //Disable the Add Item button when no text entered
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[1].isEnabled = sender.text!.count > 0
    }
}
