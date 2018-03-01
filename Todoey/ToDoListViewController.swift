//
//  ViewController.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-02-28.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit

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

    var itemArray = ["Find Mike", "Buy Eggos", "Save Hyrule"]
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let items = defaults.array(forKey: "ToDoListArray") as? [String] {
            itemArray = items
        }
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }

    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
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
                let newItem = alert.textFields?[0].text
                if newItem != "" {
                    self.itemArray.append(newItem!) //Textfield cannot be nil so unwrap is safe
                    self.defaults.set(self.itemArray, forKey: "ToDoListArray")
                    self.tableView.reloadData()
                }
            }
            ], preferredChoice: "Add Item")
        
        present(alert, animated: true, completion: nil)
    }
    
}

