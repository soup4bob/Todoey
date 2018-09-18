//
//  ViewController.swift
//  Todoey
//
//  Created by Robert Greel on 8/30/18.
//  Copyright © 2018 Robert Greel. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()

    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let colourHex = selectedCategory?.colorOfCategory else { fatalError() }
            
        title = selectedCategory?.name
        
        updateNavBar(withHexCode: colourHex)
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        updateNavBar(withHexCode: "1D98F6")
    }
    
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String) {
      
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}

        guard let navBarColour = UIColor(hexString: colourHexCode) else { fatalError() }
        
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
        searchBar.barTintColor = navBarColour
        
        // remove boarders of search bar
        navBar.backgroundImage(for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        searchBar.isTranslucent = true
        searchBar.backgroundImage = UIImage()
        
        
        
    }
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let longPressedRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_ :)))
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.addGestureRecognizer(longPressedRecognizer)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.colorOfCategory)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                cell.tintColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            
            cell.accessoryType = item.done == true ? .checkmark : .none
            
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
    
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the add item button on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    
                    currentCategory.items.append(newItem)
                    }
                }   catch {
                        print("error saving new items \(error)")
                    }
            }
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create your do"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
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
                    
                    if let item = self.todoItems?[pressedIndexPath.row] {
                        do {
                            try self.realm.write {
                                item.title = "\(task.text ?? "")"
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
    
    
    
    //MARK: - Model Manipulation Methods
    

    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)

        self.tableView.reloadData()

    }

    override func updateModel(at indexPath: IndexPath) {
        
        if let todoItemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(todoItemForDeletion)
                }
            } catch {
                print("error deleteding todoItem \(error)")
            }

        }
        
    }
    
    

}


//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
        
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}









