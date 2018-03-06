//
//  Data.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-03-06.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //Backwards linking relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") //Didn't actually use this
}
