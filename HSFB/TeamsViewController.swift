//
//  TeamsViewController.swift
//  
//
//  Created by Jacob Kohn on 1/21/16.
//
//

import Foundation
import UIKit

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user = Int()
    var teams = [NSDictionary]()
    var numBack = Int()
    
    @IBOutlet var teamsTableView: UITableView!
    @IBOutlet var rankings: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Teams"
        
        print(user)
        
        getTeams()
        
        let starImage = (UIImage(named:"star.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        rankings.setImage(starImage, forState: .Normal)
        rankings.tintColor = UIColor.greenColor()
        rankings.addTarget(self, action: "toRankings:", forControlEvents: .TouchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .Plain, target: self, action: "toUsers:")
        
        
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
        
        teamsTableView.reloadData()

    }
    
    func toUsers(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - numBack], animated: true);
    }
    
    func toRankings(sender: UIButton) {
        performSegueWithIdentifier("viewRankings", sender: nil)
    }
    
    func getTeams() {
        
        if(Reachability.isConnectedToNetwork()) {
        
            var responseString = "" as! NSString
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/getteams.php")!)
            request.HTTPMethod = "POST"
            let postString = "id=" + String(self.user)
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
                    self.teamsTableView.reloadData()
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("teamCell", forIndexPath: indexPath) as! TeamCell

        let currentDictionary = teams[indexPath.row]
        
        cell.teamNameLabel.text = currentDictionary.valueForKey("teamName") as! String
        cell.leagueNameLabel.text = currentDictionary.valueForKey("leagueName") as! String
        cell.currentPositionLabel.text = (currentDictionary.valueForKey("currentPosition") as! String) + "/" + (currentDictionary.valueForKey("numTeams") as! String)
        
        return cell
    }
    
    func parseTeams(rs: String) {
        let teams = rs.characters.split("&").map(String.init)
        for(var i=0; i<teams.count - 1; i++) {
            let curr = teams[i]
            let team = curr.characters.split("*").map(String.init)
            let teamID = team[0]
            let teamName = team[1]
            let leagueName = team[2]
            let currentPos = team[3]
            let numTeams = team[4]
            let league = team[5]
            
            let td = ["id": teamID, "teamName": teamName, "leagueName": leagueName, "currentPosition": currentPos, "numTeams": numTeams, "league": league]
            
            self.teams.append(td)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "useTeam") {
            if let indexPath = self.teamsTableView.indexPathForSelectedRow {
                let controller = segue.destinationViewController as! TeamManagerViewController
                let currentDictionary = teams[indexPath.row]
                
                controller.teamName = currentDictionary.valueForKey("teamName") as! String
                controller.user = self.user
                controller.team = Int(currentDictionary.valueForKey("id") as! String)!
                controller.league = Int(currentDictionary.valueForKey("league") as! String)!
            }
        }
        
    }
    
 
}