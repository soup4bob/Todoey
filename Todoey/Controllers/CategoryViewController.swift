//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Robert Greel on 9/5/18.
//  Copyright © 2018 Robert Greel. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
        
    }
    
    //MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
        
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func saveCategory() {
        do {
            try context.save()
        } catch {
            print("error saving category context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategory(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("error fetching category from context \(error)")
        }
    }
    
    
    
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category, Quick!", message: "stay shiny", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Punch It", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            if textField.text != "" {
                self.categoryArray.append(newCategory)
                
            self.saveCategory()
            }
            
        }
        
            alert.addAction(action)
        
            alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Get that category in here!"
        }
        
    
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    
    
    
    
}
