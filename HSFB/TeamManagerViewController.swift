//
//  TeamManagerViewController.swift
//  HSFB
//
//  Created by Jacob Kohn on 1/21/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class TeamManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var playersTable: UITableView!
    
    var players = [NSDictionary]()
    var league = Int()
    var team = Int()
    var user = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playersTable.delegate = self
        playersTable.dataSource = self
        
        
        getPlayers()
        
        
    }
    
    
    func getPlayers() {
        var responseString = "" as! NSString
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftGetPlayers.php")!)
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
                self.playersTable.reloadData()
            }
            
        }
        task.resume()
        
    }
    
    func parsePlayers(rs: String) {
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
            
            print(playerName)
            
            let pd = ["id": playerID, "playerName": playerName, "ppg": ppg, "rpg": rpg, "apg": apg, "currentPosition": currentPos]
            
            self.players.append(pd)
        }
        
        sortPlayers()
    }
    
    
    
    func sortPlayers() {
        var g = [Int]()
        var f = [Int]()
        var x = [Int]()
        var b = [Int]()
        if(players.count == 7) {
            for(var i=0; i<7; i++) {
                let currentDictionary = players[i]
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
        }
        var temp = [NSDictionary]()
        temp.append(players[g[0]])
        temp.append(players[g[1]])
        temp.append(players[f[0]])
        temp.append(players[f[1]])
        temp.append(players[x[0]])
        temp.append(players[b[0]])
        temp.append(players[b[1]])
        
        
        players = temp
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("playerCell", forIndexPath: indexPath) as! PlayerCell
        
        print("!")
        
        let currentDictionary = players[indexPath.row]

        cell.nameLabel.text = (currentDictionary.valueForKey("currentPosition") as! String) + "- " + (currentDictionary.valueForKey("playerName") as! String)
        

        let ppg = (Double(currentDictionary["rpg"] as! String)! + Double(currentDictionary["ppg"]! as! String)! + Double(currentDictionary["apg"]! as! String)!)
        
        cell.rpgLabel.text = NSString(format:"%.2f", ppg) as String
        
        cell.moveButton.tag = indexPath.row
        cell.moveButton.addTarget(self, action: "move:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}