//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Robert Greel on 9/5/18.
//  Copyright © 2018 Robert Greel. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Nvigation controller does not exist.")}
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBar.tintColor, returnFlat: true)]
        
        
    }
    
    //MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let longPressedRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_ :)))

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.addGestureRecognizer(longPressedRecognizer)

        if let category = categories?[indexPath.row] {
            
            cell.textLabel?.text = category.name
            
            guard let categoryColour = UIColor(hexString: category.colorOfCategory) else {fatalError()}
            
            cell.backgroundColor = categoryColour
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods
 
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("error saving category data \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategory() {
        
        categories = realm.objects(Category.self)
    
        tableView.reloadData()
      }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
       
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("error deleting category \(error)")
            }
            
        }

    }
    
    
    
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Push this button", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colorOfCategory = UIColor.randomFlat.hexValue()
            self.save(category: newCategory)
        }
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Get that category in here"
        }
        present(alert, animated: true, completion: nil)
    }
    


//MARK: - editing items
    @objc func longPressed(_ recognizer: UIGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.ended {
            let longPressedLocation = recognizer.location(in: self.tableView)
            if let pressedIndexPath = self.tableView.indexPathForRow(at: longPressedLocation) {
                var task = UITextField()
                let alert = UIAlertController(title: "Modify title", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Modify", style: .default) { (action) in
                    
                    if let Category = self.categories?[pressedIndexPath.row] {
                        do {
                            try self.realm.write {
                                Category.name = "\(task.text ?? "")"
                            }
                        } catch {
                            print("error updateing item name: \(error)")
                        }
                    }
                    self.tableView.reloadData()
                }
                alert.addTextField(configurationHandler: {(alertTextField) in
                    task = alertTextField
                    task.placeholder = "New item title"
                })
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }


}


