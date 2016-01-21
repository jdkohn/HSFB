//
//  ViewController.swift
//  HSFB
//
//  Created by Jacob Kohn on 1/20/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/authenticateuser.php")!)
        request.HTTPMethod = "POST"
        let postString = "username=gohawks&password=russellwilson&swift=McLovin"
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
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString as! String)")
        }
        task.resume()
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

