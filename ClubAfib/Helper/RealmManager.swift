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
            realm = try Realm()
        }
        catch{
            print("error on creating Realm")
        }
    }
    
}
