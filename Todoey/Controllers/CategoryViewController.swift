//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-03-03.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContext()
    }
    
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (categoryArray.count == 0 ? 1 : categoryArray.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray.count == 0 ? "No Categories" : categoryArray[indexPath.row].name
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
            let newCategory = Category(context: self.context)
            newCategory.name = self.alert?.textFields![0].text!
            self.categoryArray.append(newCategory)
            self.saveContext()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert?.addAction(cancelAction)
        alert?.addAction(addAction)
        
        alert?.actions[1].isEnabled = false
        alert?.preferredAction = alert?.actions[1]
        
        present(alert!, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadContext() {
        let fetchCategories: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categoryArray = try context.fetch(fetchCategories)
        } catch {
            print("Error fetching data \(error)")
        }
        tableView.reloadData()
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
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
