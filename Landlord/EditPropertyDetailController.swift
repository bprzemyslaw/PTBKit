//
//  EditPropertyDetailController.swift
//  Landlord
//
//  Created by Przemyslaw Blasiak on 07.12.2014.
//  Copyright (c) 2014 bprzemyslaw. All rights reserved.
//

import UIKit
import Parse

class EditPropertyDetailController: UITableViewController {
    weak var property: PFObject!
    var saveChanges: Bool = true // Save changes by default
    var masterController: PropertiesController!

// MARK: Outlets
    @IBOutlet weak var streetAddressField: UITextField!
    @IBOutlet weak var cityAddressField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    override func viewDidLoad() {
        self.masterController = (self.splitViewController!.viewControllers[0] as UINavigationController).topViewController as PropertiesController
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.property != nil {
            self.streetAddressField.text = self.property["address"] as? String
            self.cityAddressField.text = self.property["city"] as? String
            self.noteTextView.text = self.property["note"] as? String
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.property != nil {
            if saveChanges {
                
                // Save changes
                self.property["address"]? = self.streetAddressField.text
                self.property["city"]? = self.cityAddressField.text
                self.property["note"]? = self.noteTextView.text
                self.property.saveEventually()
                
                // Remember selected row, then reload table, and reselect the row
                let selectedRowPath: NSIndexPath! = self.masterController?.tableView.indexPathForSelectedRow()?
                self.masterController.tableView.reloadData()
                if selectedRowPath != nil {
                    self.masterController.tableView.selectRowAtIndexPath(selectedRowPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                }
            }
        }
    }
    
// MARK: Actions
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        self.saveChanges = false
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func doneAction(sender: UIBarButtonItem) {
        self.saveChanges = true
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //TODO: Next, next, ..., Done
}