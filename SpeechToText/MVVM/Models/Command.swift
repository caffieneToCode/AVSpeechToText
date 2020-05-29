//
//  Command.swift
//  SpeechToText
//
//  Created by Ashish on 28/05/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import Foundation
import RealmSwift

class Command: Object {
    
    @objc dynamic var text: String?
    
    override static func primaryKey() -> String? {
        return "text"
    }
    
    convenience init?(text: String) {
        self.init()
        self.text = text
    }
}
