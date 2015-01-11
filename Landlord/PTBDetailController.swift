//
//  PTBDetailController.swift
//  Landlord
//
//  Created by Przemyslaw Blasiak on 14.12.2014.
//  Copyright (c) 2014 bprzemyslaw. All rights reserved.
//

import UIKit
import Parse

/**
The PTBDetailController class is a UITableViewController subclass responsible for displaying values of each column of a specified Parse object.
*/
class PTBDetailController: UITableViewController {
    
// MARK: Properties
    weak var item: PFObject!
    var sectionNames = [String]()
    var cellInfos = [[Dictionary<String, AnyObject>]]()
    var shouldSaveChanges = true
    var cancelButton: UIBarButtonItem!
    var masterController: PTBMasterController! // TODO: WORKAROUND Computed property
    
// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.masterController = (self.splitViewController?.viewControllers[0] as UINavigationController).topViewController as PTBMasterController
        
        if self.item != nil {
            
            // Set grouped style
            self.tableView = UITableView(frame: self.tableView.frame, style: .Grouped)
            
            self.tableView.allowsSelection = false
            
            // Set estimated row height for the scroll indicator to assume
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.estimatedRowHeight = 60
            
            // Register reusable cells
            var nib = UINib(nibName: "PTBTextViewCell", bundle: NSBundle.mainBundle())
            self.tableView.registerNib(nib, forCellReuseIdentifier: "TextViewCell")
            nib = UINib(nibName: "PTBTextFieldCell", bundle: NSBundle.mainBundle())
            self.tableView.registerNib(nib, forCellReuseIdentifier: "TextFieldCell")
            nib = UINib(nibName: "PTBSwitchCell", bundle: NSBundle.mainBundle())
            self.tableView.registerNib(nib, forCellReuseIdentifier: "SwitchCell")
            
            // Enable editting
            self.navigationItem.rightBarButtonItem = self.editButtonItem()
            self.cancelButton = UIBarButtonItem(title: "Anuluj", style: .Plain, target: self, action: "cancelPressed:")
            
            self.title = "Szczegóły"
        } else {
            self.tableView.hidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.tableView.editing && self.shouldSaveChanges {
            self.saveChanges()
        }
    }

// MARK: TableView data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionNames.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionNames[section]
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellInfos[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellInfo = self.cellInfos[indexPath.section][indexPath.row]
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellInfo["Identifier"] as String, forIndexPath: indexPath) as UITableViewCell
        
        // When no row is selected
        if self.item != nil { // TODO: WORKAROUND why is the function called at all, when there is no item?
            if let detailCell = cell as? PTBDetailCell {
                detailCell.name = cellInfo["CellName"] as String
                if let value: AnyObject = self.item[cellInfo["ColumnName"] as String] {
                    detailCell.setValue(value)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
// MARK: Private
    func addCell(#style: PTBDetailCellStyle, sectionName: String, cellName: String, columnName: String) {
        if self.item != nil {
            var cellInfo = Dictionary<String, AnyObject>()
            cellInfo["Identifier"] = style.cellIdentifier
            cellInfo["ColumnName"] = columnName
            cellInfo["CellName"] = cellName
            
            // Find section number
            var sectionNumber: Int! = find(self.sectionNames, sectionName)
            if sectionNumber == nil { // It is a new section
                self.sectionNames.append(sectionName)
                self.cellInfos.append([cellInfo])
            } else {
                self.cellInfos[sectionNumber].append(cellInfo)
            }
        }
    }
    
// MARK: Editing
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        if !editing {
            if shouldSaveChanges {
                self.saveChanges()
            } else {
                self.tableView.reloadData() // Restore field values to previous state
                self.shouldSaveChanges = true
            }
        }
        
        showCancelButton(editing)
    }
    
    func showCancelButton(shouldShow: Bool) {
        if shouldShow {
            self.navigationItem.setLeftBarButtonItem(self.cancelButton, animated: true)
        } else {
            self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        }
    }
    
    func saveChanges() {
        if self.item != nil { // TODO: WORKAROUND This check shouldn't be necessary, the whole function should not be called in that case at all. Why is it nil, has it been deleted already?
            for (var section = 0; section < self.cellInfos.count; ++section) {
                for (var row = 0; row < self.cellInfos[section].count; ++row) {
                    let cellInfo = self.cellInfos[section][row]
                    let cell: PTBDetailCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) as PTBDetailCell
                    self.item[cellInfo["ColumnName"] as String] = cell.getValue()
                }
            }
            self.item.saveEventually()
            
            // TODO: WORKAROUND Why can't I simply call reloadRows... in master table
            // Update row title in master
            if self.masterController != nil {
                if let rowIndex = find(self.masterController.items, self.item) {
                    let cell = self.masterController.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowIndex, inSection: 0))!
                    cell.textLabel?.text = self.item[self.masterController.itemTitleColumnName!] as? String
                }
            }
        }
    }
    
    func cancel() {
        self.shouldSaveChanges = false
        self.setEditing(false, animated: true)
    }
    
// MARK: Button actions
    func cancelPressed(button: UIBarButtonItem) {
        self.cancel()
    }
}
