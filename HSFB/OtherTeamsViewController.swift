//
//  OtherTeamsViewController.swift
//  
//
//  Created by Jacob Kohn on 1/27/16.
//
//

import Foundation
import UIKit

class OtherTeamsViewController: UITableViewController {
    
    @IBOutlet weak var teamsTable: UITableView!
    
    var teams = [NSDictionary]()
    var league = Int()
    var team = Int()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Other Teams"
        
        teamsTable.delegate = self
        teamsTable.dataSource = self
        
        getTeams()
        
    }
    
    func getTeams() {
        
        if(Reachability.isConnectedToNetwork()) {
        
            var responseString = "" as! NSString
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftgetotherteams.php")!)
            request.HTTPMethod = "POST"
            let postString = "league=" + String(self.league) + "&team=" + String(self.team)
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
                    self.teamsTable.reloadData()
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("otherTeamCell", forIndexPath: indexPath) as! OtherTeamCell
        
        cell.team.text = (teams[indexPath.row]["teamname"] as! String) + ": " + (teams[indexPath.row]["record"] as! String)
        cell.owner.text = teams[indexPath.row]["owner"] as! String
        cell.p1.text = teams[indexPath.row]["p1"] as! String
        cell.p2.text = teams[indexPath.row]["p2"] as! String
        cell.p3.text = teams[indexPath.row]["p3"] as! String
        cell.p4.text = teams[indexPath.row]["p4"] as! String
        cell.p5.text = teams[indexPath.row]["p5"] as! String
        cell.p6.text = teams[indexPath.row]["p6"] as! String
        cell.p7.text = teams[indexPath.row]["p7"] as! String
        
        return cell
    }
    
    func parseTeams(rs: String) {
        self.teams = [NSDictionary]()
        
        let teams = rs.characters.split("&").map(String.init)
        for(var i=0; i<teams.count; i++) {
            let pieces = teams[i].characters.split("*").map(String.init)
            
            if(pieces.count >= 10) {
                let team = pieces[0]
                let owner = pieces[1]
                let record = pieces[2]
                let p1 = pieces[3]
                let p2 = pieces[4]
                let p3 = pieces[5]
                let p4 = pieces[6]
                let p5 = pieces[7]
                let p6 = pieces[8]
                let p7 = pieces[9]
                
                let td = ["teamname": team, "record": record, "owner": owner, "p1": p1, "p2": p2, "p3": p3, "p4": p4, "p5": p5, "p6": p6, "p7": p7]
                    
                self.teams.append(td)
            }
            
        }
    }
    

}