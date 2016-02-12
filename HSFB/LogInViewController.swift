//
//  LogInViewController.swift
//  HSFB
//
//  Created by Jacob Kohn on 1/20/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import SwiftForms
import CoreData

class LogInViewController: FormViewController {
    
    var user = Int()
    var users = [NSManagedObject]()
    
    
    override func viewDidLoad() {
        
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
        
        
        
        let form = FormDescriptor()
        
        form.title = "Log In"
        
        // Define first section
        let section1 = FormSectionDescriptor()
        
        var row: FormRowDescriptor! = FormRowDescriptor(tag: "username", rowType: .Email, title: "")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "Username", "textField.textAlignment" : NSTextAlignment.Left.rawValue]
        //row.value = ideas[idea].valueForKey("name") as! String
        section1.addRow(row)
        
        let section2 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: "password", rowType: .Password, title: "")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "Password", "textField.textAlignment" : NSTextAlignment.Left.rawValue]
        //row.value = ideas[idea].valueForKey("summary") as! String
        section2.addRow(row)
        
        form.sections = [section1, section2]
        
        self.form = form
        
        configureActions()
    }
    
    
    func configureActions() {
        
        //self.navigationItem.setHidesBackButton(false, animated: false)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log In", style: .Plain, target: self, action: "logIn:")
        
        self.title = "Log In"
    }
    
    func logIn(sender: UIBarButtonItem) {
        
        //if(self.form.formValues().valueForKey("username") != nil && self.form.formValues().valueForKey("password") != nil) {
        
//        let usrMirror = Mirror(reflecting: self.form.formValues().valueForKey("username"))
//        let passMirror = Mirror(reflecting: self.form.formValues().valueForKey("password"))
        
        if((self.form.formValues().valueForKey("username")!.isKindOfClass(NSNull)) || self.form.formValues().valueForKey("password")!.isKindOfClass(NSNull)) {
            
            sendAlert("no")
            
        } else {
            
            if(Reachability.isConnectedToNetwork()) {
            
                let username = self.form.formValues().valueForKey("username") as! String
                let password = self.form.formValues().valueForKey("password") as! String
                
                var responseString = "" as! NSString
                
                let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/authenticateuser.php")!)
                request.HTTPMethod = "POST"
                let postString = "username=" + username + "&password=" + password + "&swift=McLovin"
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                    guard error == nil && data != nil else {            // check for fundamental networking error
                        print("error=\(error)")
                        return
                    }
                    
                    if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {  // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                    print("responseString = \(responseString)")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if(responseString == "no") {
                            self.sendAlert(responseString as! String)
                        } else {
                            self.user = self.getID(responseString as String)
                            self.storeUser(self.user)
                            self.performSegueWithIdentifier("loggedIn", sender: nil)
                        }
                    }
                    
                }
                task.resume()
                
            } else {
                let alert = UIAlertController(title: "Oops!", message: "You are no longer connected to the Internet", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        
        }
    }
    
    func getID(rs: String) -> Int {
        return Int(rs)!
    }
    
    
    func sendAlert(responseString: NSString) {
        if((responseString as! String) == "yes") {
            let alert = UIAlertController(title: "Yay!", message: "You have (hypothetically) logged on", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) -> Void in
                
            }))
            
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if((responseString as! String) == "no") {
            let alert = UIAlertController(title: "Awww :(", message: "Incorect username/password combination", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) -> Void in
                
            }))
            
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "loggedIn") {
            let controller = segue.destinationViewController as! TeamsViewController
            controller.user = self.user
            controller.numBack = 3
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func storeUser(id: Int) {
        //CoreData stuff
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("User",
            inManagedObjectContext:
            managedContext)
        
        
        //creates new team object
        let userObject = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        userObject.setValue(id, forKey: "id")
        userObject.setValue(self.form.formValues().valueForKey("username") as! String, forKey: "username")
        
        var error: NSError?
        do {
            try managedContext.save()
        } catch var error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        
        self.users.insert(userObject, atIndex: self.users.count)
        
        
        do {
            try managedContext.save()
        } catch _ {
        }
        
    }
    
    
    
}
