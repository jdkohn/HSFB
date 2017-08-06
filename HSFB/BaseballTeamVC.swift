//
//  BaseballTeamVC.swift
//  HSFB
//
//  Created by Jacob Kohn on 3/9/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class BaseballTeamVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var teamTable: UITableView!
    
    var players = [NSDictionary]()
    
    var league = Int()
    var team = Int()
    var user = Int()
    var teamName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamTable.dataSource = self
        teamTable.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("baseballCell", forIndexPath: indexPath) as! BaseballPlayerCell
        
        cell.positionLabel.text = (players[indexPath.row]["position"] as! String)
        cell.nameLabel.text = (players[indexPath.row]["name"] as! String)
        cell.schoolLabel.text = (players[indexPath.row]["school"] as! String)
        cell.averageLabel.text = (players[indexPath.row]["average"] as! String)

        return cell
    }
    
    func getPlayers() {
        var responseString = "" as! NSString
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftGetBaseballPlayers.php")!)
        request.HTTPMethod = "POST"
        let postString = "team=" + String(self.team) + "&league=" + String(self.league)
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
                self.parsePlayers(responseString as! String)
                self.teamTable.reloadData()
                print(responseString as! String)
            }
            
        }
        task.resume()
        
    }
    
    func parsePlayers(rs: String) {
        
        self.players = [NSDictionary]()
        
        let players = rs.characters.split("&").map(String.init)
        for(var i=0; i<players.count; i++) {
            let curr = players[i]
            let player = curr.characters.split("*").map(String.init)
            
            let playerID = player[0]
            let playerName = player[1]
            let school = player[2]
            let average = player[3]
            let position = player[4]
            
            let pd = ["id": playerID, "playerName": playerName, "school": school, "average": average, "position": position]
            
            self.players.append(pd)
        }
        
        sortPlayers()
    }
    
    func sortPlayers() {
        var out = [Int]()
        var inf = [Int]()
        var x = [Int]()
        if(players.count == 6) {
            for(var i=0; i<7; i++) {
                let currentDictionary = players[i]
                if(currentDictionary["currentPosition"] as! String == "O") {
                    out.append(i)
                } else if(currentDictionary["currentPosition"] as! String == "I") {
                    inf.append(i)
                } else if(currentDictionary["currentPosition"] as! String == "X") {
                    x.append(i)
                }
            }
            
            var temp = [NSDictionary]()
            for(var i=0; i<out.count; i++) {
                temp.append(players[out[i]])
            }
            for(var i=0; i<inf.count; i++) {
                temp.append(players[inf[i]])
            }
            for(var i=0; i<x.count; i++) {
                temp.append(players[x[i]])
            }
            
            
            players = temp
        }
    }
    
    

    
    
}
