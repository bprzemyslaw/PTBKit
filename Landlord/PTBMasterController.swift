//
//  PTBMasterController.swift
//  Landlord
//
//  Created by Przemyslaw Blasiak on 18.11.2014.
//  Copyright (c) 2014 bprzemyslaw. All rights reserved.
//

import UIKit
import Parse

/**
The PTBMasterController class is a UITableViewController subclass responsible for displaying each object of a given Parse class as a row.
*/
class PTBMasterController: UITableViewController, UISplitViewControllerDelegate {

// MARK: Public properties
    var detailController: PTBDetailController! { // Read-only computed property
        return (self.splitViewController?.viewControllers[1] as UINavigationController).topViewController as PTBDetailController
    }
    
// MARK: Public methods
    func loadObjects(#className: String, titleColumnName: String) {
        self.objectClassName = className
        self.objectTitleColumnName = titleColumnName
        self.updateObjects()
    }
    
// MARK: Private properties
    var objectClassName: String?
    var objectTitleColumnName: String?
    var objects = [PFObject]()

// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        
        // Add an add action
        let addSelector: Selector = Selector("addObject")
        if self.respondsToSelector(addSelector) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: addSelector)
        }
        
        // Add a refresh action
        let updateSelector: Selector = Selector("updateObjects")
        if self.respondsToSelector(updateSelector) {
            self.refreshControl?.addTarget(self, action: updateSelector, forControlEvents: UIControlEvents.ValueChanged)
        }
        
        // Add a log out action
        let logOutSelector: Selector = Selector("logOut")
        if self.respondsToSelector(logOutSelector) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Wyloguj", style: UIBarButtonItemStyle.Plain, target: self, action: logOutSelector)
        }
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Register notifications
        let userDidLogInSelector: Selector = Selector("userDidLogIn:")
        if self.respondsToSelector(userDidLogInSelector) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: userDidLogInSelector, name: PTBUserDidLogInNotification, object: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() == nil {
            self.presentLoginScreen()
        }
    }
    
// MARK: - TableView data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = self.objectClassName! + "Cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        var object: PFObject = self.objects[indexPath.row]
        if (objectTitleColumnName != nil) {
            cell!.textLabel?.text = (object[objectTitleColumnName] as String)
        }
        
        var bgColorView = UIView()  // TODO: TEMPORARY COLOR
        bgColorView.backgroundColor = UIColor(red: 253/255, green: 166/255, blue: 13/255, alpha: 1)  // TODO: TEMPORARY COLOR
        cell?.selectedBackgroundView = bgColorView  // TODO: TEMPORARY COLOR
        
        return cell!
    }
    
// MARK: TableView delegate
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete selected object
            self.removeObject(indexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
// MARK: Update data
    func updateObjects() {
        if (PFUser.currentUser() != nil) {
            var query = PFQuery(className: self.objectClassName)
            query.whereKey("userId", equalTo: PFUser.currentUser())
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                self.refreshControl?.endRefreshing()
                
                // Succeeded
                if error == nil {
                    self.objects = objects! as [PFObject]
                    self.refresh()
                    
                // Failed
                } else {
                    
                    // Present Alert
                    var alert = UIAlertController(type: .Error, error: error)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func addObject() {
        if (PFUser.currentUser() != nil) {
        
            // Create an object
            var newObject = PFObject(className: self.objectClassName)
            newObject["userId"] = PFUser.currentUser()
            newObject[self.objectTitleColumnName] = "Nowy"
            
            // Add the object
            self.objects.insert(newObject, atIndex: self.objects.count)
            newObject.saveEventually()

            // Insert new row
            self.tableView.beginUpdates()
            let rowPath = NSIndexPath(forRow: self.objects.count - 1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([rowPath!], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            
            self.selectItemAtIndexPath(rowPath)
            self.detailController.setEditing(true, animated: true)
        }
    }
    
    func removeObject(#indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("ShowDetailView", sender: self) // Present blank detail view
        
        // Delete the object
        tableView.beginUpdates()
        self.objects.removeAtIndex(indexPath.row).deleteInBackgroundWithBlock(nil)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
// MARK: Table interaction
    func refresh() {
        
        // TODO: Preserve selection
        self.tableView.reloadData()
    }
    
    func selectItemAtIndexPath(path: NSIndexPath) {
        self.tableView.selectRowAtIndexPath(path, animated: true, scrollPosition: .None)
        self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: .None, animated: false)
        self.performSegueWithIdentifier("ShowDetailView", sender: self)
    }

// MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowDetailView") {
            
            // Pass data to detail controller if any row is selected
            if self.tableView.indexPathForSelectedRow() != nil {
                let detailController: PTBDetailController! = (segue.destinationViewController as UINavigationController).topViewController as? PTBDetailController
                if detailController != nil {
                    detailController.object = self.objects[self.tableView.indexPathForSelectedRow()!.row]
                }
            }
        }
    }
    
// MARK: Login/Logout
    func presentLoginScreen(animated: Bool = true) {
        var storyboard = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        var PTBLoginController = storyboard.instantiateInitialViewController() as UIViewController
        self.presentViewController(PTBLoginController, animated: animated, completion: nil)
    }
    
    func logOut() {
        
        // Ask to confirm
        var alert = UIAlertController(title: "Potwierdzenie", message: "Chcesz się wylogować?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Anuluj", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Tak", style: UIAlertActionStyle.Default,
            handler: { (UIAlertAction action) -> Void in
                PFUser.logOut()
                
                // Clear data
                self.objects = []
                
                // Go to Log In screen
                self.presentLoginScreen()
            }
            ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func userDidLogIn(notification: NSNotification) {
        self.updateObjects()
    }
}
