//
//  VoiceCommandCell.swift
//  SpeechToText
//
//  Created by Ashish on 28/05/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import UIKit

class VoiceCommandCell: UITableViewCell {
    
    var command: Command? {
        didSet {
            setCell()
        }
    }
    
    func setCell() {
        self.textLabel?.text = command?.text
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}
