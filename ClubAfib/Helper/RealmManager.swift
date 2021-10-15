//
//  RealmManager.swift
//  Helper
//
//  Created by Rener on 8/12/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit
import RealmSwift

class RealmManager {
    
    static let `default` = RealmManager()
    
    var realm: Realm!

    private init(){
        do{
            let config = Realm.Configuration(schemaVersion: 1)
            realm = try Realm(configuration: config)
        }
        catch{
            print("Realm schema version may need to be incremented or the data may need to be migrated manually")
            let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            do {
                realm = try Realm(configuration: config)
            } catch {
                print("error on creating Realm")
            }
        }
    }
    
}
