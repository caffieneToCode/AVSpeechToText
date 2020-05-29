//
//  DataManager.swift
//  SmartServ
//
//  Created by Ashish Verma on 24/05/20.
//  Copyright © 2020 com.verma.ashish. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager {
    
    public static let sharedInstance: DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    private init() {}
    
    func getCommands() -> [Command]? {
        
        var commands: [Command]?
        do {
            let realm = try Realm()
            let results = realm.objects(Command.self)
            if !results.isEmpty {
                commands = Array(results)
            }
            return commands
        } catch {
            print("Realm not found")
        }
        return commands
    }
    
    func add(_ command: Command) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(command, update: .modified)
            }
        } catch {
            print("Realm not found")
        }
    }
    
    func filterCommandsContaining(text: String) -> [Command]? {
        if let realm = try? Realm() {
            let queryString = getQueryString(for: text)
            let predicate = NSPredicate(format: "\(queryString)")
            return Array(realm.objects(Command.self).filter(predicate))
        } else {
            print("Unable to retrieve objects from Realm")
            return nil
        }
    }
    
    func getQueryString(for text: String) -> String {
        let keywords = text.split(separator: " ")
        var queryString = ""
        var prefixCount = 0
        for keyword in keywords {
            if prefixCount == 0 {
                queryString += "text CONTAINS[c] "
                queryString += "'\(keyword)"
                prefixCount += 1
            } else {
                queryString += " \(keyword)"
            }
        }
        return "\(queryString)'"
    }
}
