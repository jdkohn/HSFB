//
//  AddPlayersViewController.swift
//  HSFB
//
//  Created by Jacob Kohn on 1/25/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class AddPlayersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var addTable: UITableView!
    
    var freeAgents = [NSDictionary]()
    var team = [NSDictionary]()
    var league = Int()
    var user = Int()
    var currTeam = Int()
    
    
    var playerToAdd = Int()
    
    var adding = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Player"
        instructionsLabel.text = "Select a Player to Add:"
        
        adding = true
        
        addTable.delegate = self
        addTable.dataSource = self
        
        
        
        //get free agents
        
        getTeam()
        
        getFreeAgents()
        
        addTable.reloadData()
    }
    
    func getFreeAgents() {
        var responseString = "" as! NSString
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftgetfreeagents.php")!)
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
            self.parseFreeAgents(responseString as! String)
            self.addTable.reloadData()
            }
            
        }
        task.resume()
    }
    
    func parseFreeAgents(rs: String) {
        let players = rs.characters.split("&").map(String.init)
        for(var i=0; i<players.count - 1; i++) {
            let curr = players[i]
            let player = curr.characters.split("*").map(String.init)
            
            let playerName = player[0]
            let fppg = player[1]
            let playerID = player[2]
            let position = player[3]

            
            let pd = ["id": playerID, "name": playerName, "fppg": fppg, "position": position]
            
            self.freeAgents.append(pd)
        }
    }
    
    func getTeam() {
        var responseString = "" as! NSString
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftGetPlayers.php")!)
        request.HTTPMethod = "POST"
        let postString = "team=" + String(self.currTeam) + "&league=" + String(self.league)
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
        print("swiftGetPlayers.php = \(responseString)")
        
        dispatch_async(dispatch_get_main_queue()) {
        self.parsePlayers(responseString as! String)
        self.addTable.reloadData()
        }
        
        }
        task.resume()
    }
    
    func parsePlayers(rs: String) {
        
        var team = [NSDictionary]()
        
        let players = rs.characters.split("&").map(String.init)
        for(var i=0; i<players.count; i++) {
        let curr = players[i]
        let player = curr.characters.split("*").map(String.init)
        
        let playerID = player[0]
        let playerName = player[1]
        let ppg = player[2]
        let rpg = player[3]
        let apg = player[4]
        let currentPos = player[5]
        let position = player[6]
        
        let fppg = (Double(ppg)! + Double(rpg)! + Double(apg)!)
        let fp = String(format:"%f", fppg)
            
        let pd = ["id": playerID, "name": playerName, "fppg": fp, "currentPosition": currentPos, "position": position]
        
        self.team.append(pd)
        }
        
        sortPlayers()
    }
    
    
    
    func sortPlayers() {
        var g = [Int]()
        var f = [Int]()
        var x = [Int]()
        var b = [Int]()
        if(team.count == 7) {
        for(var i=0; i<7; i++) {
        let currentDictionary = team[i]
        if(currentDictionary["currentPosition"] as! String == "G") {
        g.append(i)
    } else if(currentDictionary["currentPosition"] as! String == "F") {
        f.append(i)
    } else if(currentDictionary["currentPosition"] as! String == "X") {
        x.append(i)
    } else {
        b.append(i)
        }
        }
        
        var temp = [NSDictionary]()
        
        for(var i=0; i<g.count; i++) {
        temp.append(team[g[i]])
        }
        for(var i=0; i<f.count; i++) {
        temp.append(team[f[i]])
        }
        for(var i=0; i<x.count; i++) {
        temp.append(team[x[i]])
        }
        for(var i=0; i<b.count; i++) {
        temp.append(team[b[i]])
        }
        
        
        team = temp
        }
    }

    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        if(adding) {
                return freeAgents.count
            } else {
                return team.count
            }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCellWithIdentifier("addCell", forIndexPath: indexPath) as! AddCell
        
                cell.addButton.removeTarget(self, action: "addPlayer:", forControlEvents: .TouchUpInside)
                cell.addButton.removeTarget(self, action: "dropPlayer:", forControlEvents: .TouchUpInside)
                
                if(adding) {
                cell.nameLabel.text = (freeAgents[indexPath.row]["name"] as! String) + ", " + (freeAgents[indexPath.row]["position"] as! String)
                let fppg = freeAgents[indexPath.row]["fppg"] as! String
                    
                    
                    
                if(Double(freeAgents[indexPath.row]["fppg"] as! String) >= 10.0) {
                    if(fppg.characters.count > 5) {
                        cell.pointsLabel.text = fppg.substringWithRange(Range<String.Index>(start: fppg.startIndex, end: fppg.startIndex.advancedBy(5))) //"Hello, playground"
                    } else {
                        cell.pointsLabel.text = fppg
                    }
                } else {
                    if(fppg.characters.count > 4) {
                        cell.pointsLabel.text = fppg.substringWithRange(Range<String.Index>(start: fppg.startIndex, end: fppg.startIndex.advancedBy(4))) //"Hello, playground"
                    } else {
                        cell.pointsLabel.text = fppg
                    }
                }
                    
                    
                    

                let addButton = (UIImage(named:"plusButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
                cell.addButton.setImage(addButton, forState: .Normal)
                cell.addButton.tintColor = UIColor.greenColor()
                cell.addButton.tag = Int(freeAgents[indexPath.row]["id"] as! String)!
                cell.addButton.addTarget(self, action: "addPlayer:", forControlEvents: .TouchUpInside)
            } else {
                cell.nameLabel.text = (team[indexPath.row]["name"] as! String) + ", " + (team[indexPath.row]["position"] as! String)
                    
                    
                let fppg = team[indexPath.row]["fppg"] as! String
                
                
                
                if(Double(team[indexPath.row]["fppg"] as! String) >= 10.0) {
                    if(fppg.characters.count > 5) {
                        cell.pointsLabel.text = fppg.substringWithRange(Range<String.Index>(start: fppg.startIndex, end: fppg.startIndex.advancedBy(5))) //"Hello, playground"
                    } else {
                        cell.pointsLabel.text = fppg
                    }
                } else {
                    if(fppg.characters.count > 4) {
                        cell.pointsLabel.text = fppg.substringWithRange(Range<String.Index>(start: fppg.startIndex, end: fppg.startIndex.advancedBy(4))) //"Hello, playground"
                    } else {
                        cell.pointsLabel.text = fppg
                    }
                }
                    
                    
                    
                    
                    
                let dropButton = (UIImage(named:"dropButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
                cell.addButton.setImage(dropButton, forState: .Normal)
                cell.addButton.tintColor = UIColor.redColor()
                cell.addButton.tag = Int(team[indexPath.row]["id"] as! String)!
                cell.addButton.addTarget(self, action: "dropPlayer:", forControlEvents: .TouchUpInside)
                }
                return cell
    }
    
    func addPlayer(sender: UIButton) {
        playerToAdd = sender.tag
        adding = false
        addTable.reloadData()
        self.title = "Drop Player"
        instructionsLabel.text = "Select a Player to Drop:"
        
    }
    
    func dropPlayer(sender: UIButton) {
        
        var responseString = "" as! NSString
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftadddrop.php")!)
        request.HTTPMethod = "POST"
        let postString = "league=" + String(self.league) + "&team=" + String(self.currTeam) + "&add=" + String(self.playerToAdd) + "&drop=" + String(sender.tag)
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
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
            }
            
        }
        task.resume()

    }
    
    
}

