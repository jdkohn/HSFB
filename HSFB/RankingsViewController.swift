//
//  RankingsViewController.swift
//  HSFB
//
//  Created by Jacob Kohn on 1/23/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class RankingsViewController: UITableViewController {
    @IBOutlet var rankingsTable: UITableView!
    
    var players = [NSDictionary]()
    var team = Int()
    var user = Int()
    var league = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Rankings"
        
        getRankings()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("rankingCell", forIndexPath: indexPath) as! RankingCell
        
        cell.nameLabel.text = String(indexPath.row + 1) + ": " + (players[indexPath.row]["name"] as! String)
        cell.schoolLabel.text = players[indexPath.row]["school"] as! String
        
        let fppg = players[indexPath.row]["fppg"] as! String
        
        
        if(Double(players[indexPath.row]["fppg"] as! String) >= 10.0) {
            if(fppg.characters.count > 5) {
                cell.fppgLabel.text = fppg.substringWithRange(Range<String.Index>(start: fppg.startIndex, end: fppg.startIndex.advancedBy(5))) //"Hello, playground"
            } else {
                cell.fppgLabel.text = fppg
            }
        } else {
            if(fppg.characters.count > 4) {
                cell.fppgLabel.text = fppg.substringWithRange(Range<String.Index>(start: fppg.startIndex, end: fppg.startIndex.advancedBy(4))) //"Hello, playground"
            } else {
                cell.fppgLabel.text = fppg
            }
        }
        
        
        return cell
    }
    
    func getRankings() {
        var responseString = "" as! NSString
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftgetrankings.php")!)
//        request.HTTPMethod = "POST"
//        let postString = "playerOne=" + String(player) + "&league=" + String(self.league) + "&playerTwo=" + String(player2)
//        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
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
                self.parsePlayers(responseString as! String)
                self.rankingsTable.reloadData()
            }
            
        }
        task.resume()
    }
    
    func parsePlayers(rs: String) {
        
        self.players = [NSDictionary]()
        
        let players = rs.characters.split("&").map(String.init)
        for(var i=0; i<players.count - 1; i++) {
            let curr = players[i]
            let player = curr.characters.split("*").map(String.init)
            
            let name = player[0]
            let fppg = player[1]
            let school = player[2]
            
            let pd = ["name": name, "school": school, "fppg": fppg]
            
            self.players.append(pd)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "useUser") {
            let controller = segue.destinationViewController as! TeamsViewController
            controller.user = sender!.tag
        }
        
    }
    
    
    
}
