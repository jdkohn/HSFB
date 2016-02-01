//
//  UsersViewController.swift
//  HSFB
//
//  Created by Jacob Kohn on 1/22/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var users = [NSManagedObject]()
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var usersTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"User")
        let error: NSError?
        var fetchedResults = [NSManagedObject]()
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        users = fetchedResults
        
        usersTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"User")
        let error: NSError?
        var fetchedResults = [NSManagedObject]()
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        users = fetchedResults
        
        if(users.count == 0) {
            performSegueWithIdentifier("addNewUser", sender: nil)
        }
        
        usersTable.dataSource = self
        usersTable.delegate = self
        plusButton.addTarget(self, action: "addNewUser:", forControlEvents: .TouchUpInside)
        
        self.title = "Welcome!"
        
        configureNavBar()
    }
    
    
        func configureNavBar() {
        let blue = UIColor(red: 0.678, green: 0.847, blue: 0.901, alpha: 1.0)
        
        self.navigationController?.navigationBar.barTintColor = blue
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserCell
        
        cell.usernameLabel.text = users[indexPath.row].valueForKey("username") as! String
        cell.useButton.tag = users[indexPath.row].valueForKey("id") as! Int
        cell.useButton.addTarget(self, action: "use:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    
    func use(sender: UIButton) {
        performSegueWithIdentifier("useUser", sender: sender)
    }
    
    func addNewUser(sender: UIButton) {
        performSegueWithIdentifier("addNewUser", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "useUser") {
            let controller = segue.destinationViewController as! TeamsViewController
            controller.user = sender!.tag
            controller.numBack = 2
        }
        
    }
    
    
    
}


