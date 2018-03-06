//
//  AppDelegate.swift
//  Todoey
//
//  Created by Keegan Jebb on 2018-02-28.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm() //Underscore becuase we are not using the realm that is being created
        } catch {
            print("Error init new realm \(error)")
        }
        
        return true
    }


}

