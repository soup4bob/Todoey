//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Robert Greel on 9/13/18.
//  Copyright © 2018 Robert Greel. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    var tableDataSourceEmpty = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 65.0
        tableView.separatorStyle = .none
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
//        let longPressedRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_ :)))
//        cell.addGestureRecognizer(longPressedRecognizer)
        cell.delegate = self
        
        if tableDataSourceEmpty {
            cell.textLabel?.text = "No Items"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = FlatGray()
            cell.backgroundColor = UIColor(white: 1, alpha: 1)
        } else {
            cell.textLabel?.textAlignment = .left
        }
        
        return cell
    }
    
//Mark: - Swipe Cell Delegate Methods
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        if tableDataSourceEmpty {
            // If there are no items, don't add swipe actions to a placeholder cell.
            // There's no point in trying to delete it because it will automatically
            // disappear when items are added.
            return []
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.updateModel(at: indexPath)
            self.tableView.beginUpdates()
            //If there are no data in datasource, insert a row into tableview - otherwise, the app will crash
            if self.tableDataSourceEmpty {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
            }
            action.fulfill(with: .delete)
            
            self.tableView.endUpdates()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        //update our data model
    }
    
    
}



