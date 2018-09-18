//
//  Item.swift
//  Todoey
//
//  Created by Robert Greel on 9/7/18.
//  Copyright © 2018 Robert Greel. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
