//
//  Category.swift
//  Todoey
//
//  Created by Robert Greel on 9/7/18.
//  Copyright © 2018 Robert Greel. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class Category : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var colorOfCategory : String = ""
    let items = List<Item>()
}
