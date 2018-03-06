//
//  Category.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-03-06.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

//Object is saveable to Realm
class Category: Object {
    @objc dynamic var name: String = ""
    
    //Forward linking relationship
    let items = List<Item>() //List is from Realm
    
}
