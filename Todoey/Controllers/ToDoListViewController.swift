//
//  ViewController.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-02-28.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit

//Copied from the internet
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


class ToDoListViewController: UITableViewController {

    var itemArray = [ListItem]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist") //Singleton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row] //Readability
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none //Ternary operator
        
        return cell
    }

    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done //Toggle boolean
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Action
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
//
//        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
//            print("Success")
//        }
//
//        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//
//        alert.addAction(cancel)
//        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
        }
        
        //Using Extension
        alert.addActions(actions: [
            UIAlertAction(title: "Cancel", style: .default, handler: nil),
            UIAlertAction(title: "Add Item", style: .default) { (action) in
                let newItemTitle = alert.textFields?[0].text
                if newItemTitle != "" {
                    self.itemArray.append(ListItem(itemTitle: newItemTitle!)) //Textfield cannot be nil so unwrap is safe
                    self.saveItems()
                }
            }
            ], preferredChoice: "Add Item")
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manipulation Methods
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems() {
        
        if let data = try? Data(contentsOf: dataFilePath!) { //Different method of trying a function
            
            let decoder = PropertyListDecoder()
            
            do {
            itemArray = try decoder.decode([ListItem].self, from: data)
            } catch {
                print("Error decoding \(error)")
            }
        }
    }
    
}

