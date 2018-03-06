//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-03-03.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//


import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm() //This is ok for the second Realm initialization

    var category: Results<Category>? //Auto updates
    
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (category?.count ?? 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = category?[indexPath.row].name ?? "No Categories"
        return cell
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        alert?.addTextField(configurationHandler: { (alertText) in
            alertText.placeholder = "Category Name"
            alertText.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })
        
        let addAction = UIAlertAction(title: "Add Category", style: .default) { (addAction) in
            let newCategory = Category()
            newCategory.name = (self.alert?.textFields?[0].text)!
            self.saveCategory(category: newCategory)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert?.addAction(cancelAction)
        alert?.addAction(addAction)
        
        alert?.actions[1].isEnabled = false
        alert?.preferredAction = alert?.actions[1]
        
        present(alert!, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        category = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = category?[indexPath.row]
        }
    }
    
    
}


//MARK: - Alert Functionality Extension

extension CategoryViewController {
    
    //Disable the Add Item button when no text entered
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[1].isEnabled = sender.text!.count > 0
    }
}
