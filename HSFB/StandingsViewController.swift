//
//  StandingsViewController.swift
//  
//
//  Created by Jacob Kohn on 1/26/16.
//
//

import Foundation
import UIKit

class StandingsViewController: UITableViewController {
    
    @IBOutlet weak var standingsTable: UITableView!
    
    var teams = [NSDictionary]()
    var team = Int()
    var league = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Standings"
        
        standingsTable.delegate = self
        standingsTable.dataSource = self
        
        getTeams()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return teams.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("standingsCell", forIndexPath: indexPath) as! StandingsCell

        cell.teamNameLabel.text = teams[indexPath.row]["teamName"] as! String
        cell.ownerNameLabel.text = teams[indexPath.row]["owner"] as! String
        cell.recordLabel.text = teams[indexPath.row]["record"] as! String
        
        
        
        return cell
    }
    
    func getTeams() {
        
        if(Reachability.isConnectedToNetwork()) {
        
            var responseString = "" as! NSString
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftgetstandings.php")!)
            request.HTTPMethod = "POST"
            let postString = "league=" + String(self.league)
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
                    self.parseTeams(responseString as! String)
                    self.standingsTable.reloadData()
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
    
    func parseTeams(rs: String) {
        let teams = rs.characters.split("&").map(String.init)
        for(var i=0; i<teams.count; i++) {
            let curr = teams[i]
            let team = curr.characters.split("*").map(String.init)
            let teamID = team[0]
            let teamName = team[1]
            let owner = team[2]
            let record = team[3]
            
            let td = ["id": teamID, "teamName": teamName, "owner": owner, "record": record]
            
            self.teams.append(td)
        }
    }

    
    
}