//
//  ListItem.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-03-01.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

//Encodable protocol says all properties must be standard data types
class ListItem: Codable { //Codable is the same as Encoding + Decoding
    var title: String = ""
    var done: Bool = false
    
    init(itemTitle: String) {
        title = itemTitle
    }
}
