//
//  Category.swift
//  Todoey
//
//  Created by Robert Greel on 9/7/18.
//  Copyright © 2018 Robert Greel. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
