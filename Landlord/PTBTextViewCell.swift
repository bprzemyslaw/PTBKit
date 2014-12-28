//
//  PTBTextViewCell.swift
//  Landlord
//
//  Created by Przemyslaw Blasiak on 14.12.2014.
//  Copyright (c) 2014 bprzemyslaw. All rights reserved.
//

import UIKit

class PTBTextViewCell: PTBTableViewCell {
    
// MARK: Outlets
    @IBOutlet weak var textView: UITextView!
    
    override func setValue(value: AnyObject) {
        self.textView.text = value as NSString
    }
    
    override func getValue() -> AnyObject {
        return self.textView.text
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.textView.editable = editing
    }
}
