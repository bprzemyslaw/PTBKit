//
//  PropertiesController.swift
//  Landlord
//
//  Created by Przemyslaw Blasiak on 02.11.2014.
//  Copyright (c) 2014 bprzemyslaw. All rights reserved.
//

import UIKit
import Parse

class PropertiesController: PTBTableViewController, UISplitViewControllerDelegate {
    
// MARK: Properties
    var propertyTypes = [PFObject]()
    
// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.delegate = self
        
        // Customize the table
        self.itemClassName = "Property"
        self.itemTitleColumnName = "streetAddress"
        
        // Add a log out action
        let logOutSelector: Selector = Selector("logOut")
        if self.respondsToSelector(logOutSelector) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Wyloguj", style: UIBarButtonItemStyle.Plain, target: self, action: logOutSelector)
        }

        // Set property types
        let typesQuery = PFQuery(className: "PropertyType")
        typesQuery.findObjectsInBackgroundWithBlock {
            (propertyTypes: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.propertyTypes = propertyTypes as [PFObject]
            }
        }
    }

// MARK: TableVC delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Pass data to detail controller
        let detailController: PropertyDetailController! = (self.splitViewController?.viewControllers[1] as UINavigationController).topViewController as? PropertyDetailController
        if detailController != nil {
            detailController.property = self.items[indexPath.row]
        }
    }
    
// MARK: Log in/out
    func logOut() {
        
        // Ask to confirm
        var alert = UIAlertController(title: "Potwierdzenie", message: "Chcesz się wylogować?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Anuluj", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Tak", style: UIAlertActionStyle.Default,
            handler: { (UIAlertAction action) -> Void in
                PFUser.logOut()
                
                // Clear data
                self.items = []
                
                // Go to Log In screen
                self.performSegueWithIdentifier("LogOutSegue", sender: self)
            }
            ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
