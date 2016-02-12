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
    @IBOutlet weak var bottomLeftButton: UIButton!
    @IBOutlet weak var bottomRightButton: UIButton!
    
    @IBOutlet weak var playersTable: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var standingsButton: UIButton!
    @IBOutlet weak var otherTeamsButton: UIButton!
    
    var players = [NSDictionary]()
    var league = Int()
    var team = Int()
    var user = Int()
    var teamName = String()
    
    var numBench = Int()
    var numFlex = Int()
    var numForwards = Int()
    var numGuards = Int()
    
    var onePressed = Bool()
    
    var moving = Bool()
    var playerToMove = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = teamName
        
        playersTable.delegate = self
        playersTable.dataSource = self
        
        let plusImage = (UIImage(named:"plusButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        plusButton.setImage(plusImage, forState: .Normal)
        plusButton.tintColor = UIColor.greenColor()
        plusButton.addTarget(self, action: "addPlayer:", forControlEvents: .TouchUpInside)
        
        let standingsImage = (UIImage(named:"standings.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        standingsButton.setImage(standingsImage, forState: .Normal)
        standingsButton.tintColor = UIColor.greenColor()
        standingsButton.addTarget(self, action: "viewStandings:", forControlEvents: .TouchUpInside)
        
        let otherTeamsImage = (UIImage(named:"teamsButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        otherTeamsButton.setImage(otherTeamsImage, forState: .Normal)
        otherTeamsButton.tintColor = UIColor.greenColor()
        otherTeamsButton.addTarget(self, action: "viewOtherTeams:", forControlEvents: .TouchUpInside)
        
        moving = false
        playerToMove = -1
        
        //getPlayers()
        
    }
    
    func viewOtherTeams(sender: UIButton) {
        performSegueWithIdentifier("viewOtherTeams", sender: nil)
    }
    
    func viewStandings(sender: UIButton) {
        performSegueWithIdentifier("viewStandings", sender: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        getPlayers()
    }
    
    func addPlayer(sender: UIButton) {
        performSegueWithIdentifier("addPlayer", sender: nil)
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
                self.onePressed = false
                self.parsePlayers(responseString as! String)
                self.bottomRightButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
                self.bottomLeftButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
                self.bottomRightButton.hidden = true
                self.bottomLeftButton.hidden = true
                self.playersTable.reloadData()
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
            let ppg = player[2]
            let rpg = player[3]
            let apg = player[4]
            let currentPos = player[5]
            let position = player[6]
            
            let pd = ["id": playerID, "playerName": playerName, "ppg": ppg, "rpg": rpg, "apg": apg, "currentPosition": currentPos, "position": position]
            
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
            
            var temp = [NSDictionary]()
            numGuards = 0
            numForwards = 0
            numFlex = 0
            numBench = 0
            for(var i=0; i<g.count; i++) {
                temp.append(players[g[i]])
                numGuards++
            }
            for(var i=0; i<f.count; i++) {
                temp.append(players[f[i]])
                numForwards++
            }
            for(var i=0; i<x.count; i++) {
                temp.append(players[x[i]])
                numFlex++
            }
            for(var i=0; i<b.count; i++) {
                temp.append(players[b[i]])
                numBench++
            }
            
            
            players = temp
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(players.count)
        return players.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("playerCell", forIndexPath: indexPath) as! PlayerCell
        
        cell.moveButton.removeTarget(self, action: "here:", forControlEvents: .TouchUpInside)
        cell.moveButton.removeTarget(self, action: "move:", forControlEvents: .TouchUpInside)
        cell.moveButton.removeTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
        
        let currentDictionary = players[indexPath.row]
        
        cell.nameLabel.text = (currentDictionary.valueForKey("currentPosition") as! String) + "- " + (currentDictionary.valueForKey("playerName") as! String)
        
        
        let ppg = (Double(currentDictionary["rpg"] as! String)! + Double(currentDictionary["ppg"]! as! String)! + Double(currentDictionary["apg"]! as! String)!)
        
        cell.rpgLabel.text = NSString(format:"%.2f", ppg) as String
        if(!moving) {
            cell.moveButton.tag = indexPath.row
            cell.moveButton.addTarget(self, action: "move:", forControlEvents: .TouchUpInside)
            cell.moveButton.setTitle("Move", forState: .Normal)
            cell.moveButton.backgroundColor = UIColor.greenColor()
            cell.moveButton.hidden = false
        } else {
            if(players[playerToMove]["currentPosition"] as! String == "G") {
                if(players[indexPath.row]["currentPosition"] as! String == "G") {
                    cell.moveButton.hidden = true
                } else if(players[indexPath.row]["currentPosition"] as! String == "F") {
                    cell.moveButton.hidden = true
                } else if(players[indexPath.row]["currentPosition"] as! String == "X") {
                    cell.moveButton.backgroundColor = UIColor.redColor()
                    cell.moveButton.setTitle("Here", forState: .Normal)
                    cell.moveButton.tag = indexPath.row
                    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                } else if(players[indexPath.row]["currentPosition"] as! String == "B") {
                    if(players[indexPath.row]["position"] as! String == "G") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    } else {
                        cell.moveButton.hidden = true
                    }
                }
            } else if(players[playerToMove]["currentPosition"] as! String == "F") {
                if(players[indexPath.row]["currentPosition"] as! String == "G") {
                    cell.moveButton.hidden = true
                } else if(players[indexPath.row]["currentPosition"] as! String == "F") {
                    cell.moveButton.hidden = true
                } else if(players[indexPath.row]["currentPosition"] as! String == "X") {
                    cell.moveButton.backgroundColor = UIColor.redColor()
                    cell.moveButton.setTitle("Here", forState: .Normal)
                    cell.moveButton.tag = indexPath.row
                    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                } else if(players[indexPath.row]["currentPosition"] as! String == "B") {
                    if(players[indexPath.row]["position"] as! String == "F") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    } else {
                        cell.moveButton.hidden = true
                    }
                }
            } else if(players[playerToMove]["currentPosition"] as! String == "X") {
                
                if((players[playerToMove]["position"] as! String) == "G") {
                    
                    if(players[indexPath.row]["currentPosition"] as! String == "G") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    } else if(players[indexPath.row]["currentPosition"] as! String == "F") {
                        cell.moveButton.hidden = true
                    } else if(players[indexPath.row]["currentPosition"] as! String == "B") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    }
                    
                } else {
                    
                    if(players[indexPath.row]["currentPosition"] as! String == "G") {
                        cell.moveButton.hidden = true
                    } else if(players[indexPath.row]["currentPosition"] as! String == "F") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    } else if(players[indexPath.row]["currentPosition"] as! String == "B") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    }
                }
            } else if(players[playerToMove]["currentPosition"] as! String == "B") {
                
                if((players[playerToMove]["position"] as! String) == "G") {
                    
                    if(players[indexPath.row]["currentPosition"] as! String == "G") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    } else if(players[indexPath.row]["currentPosition"] as! String == "F") {
                        cell.moveButton.hidden = true
                    } else if(players[indexPath.row]["currentPosition"] as! String == "X") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    } else if(players[indexPath.row]["currentPosition"] as! String == "B") {
                        cell.moveButton.hidden = true
                    }
                    
                } else {
                    
                    if(players[indexPath.row]["currentPosition"] as! String == "G") {
                        cell.moveButton.hidden = true
                    } else if(players[indexPath.row]["currentPosition"] as! String == "F") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    } else if(players[indexPath.row]["currentPosition"] as! String == "X") {
                        cell.moveButton.backgroundColor = UIColor.redColor()
                        cell.moveButton.setTitle("Here", forState: .Normal)
                        cell.moveButton.tag = indexPath.row
                        cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
                    } else if(players[indexPath.row]["currentPosition"] as! String == "B") {
                        cell.moveButton.hidden = true
                    }
                }
                
            }
            if(indexPath.row == playerToMove) {
                cell.moveButton.backgroundColor = UIColor.grayColor()
                cell.moveButton.setTitle("Cancel", forState: .Normal)
                cell.moveButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
                cell.moveButton.hidden = false
            }
        }
        
        return cell
    }
    
    func cancel(sender: UIButton) {
        playerToMove = -1
        moving = false
        bottomLeftButton.hidden = true
        bottomRightButton.hidden = true
        playersTable.reloadData()
        
    }
    
    func configureBottomButtons(position: String, index: Int) {
        
        bottomRightButton.tintColor = UIColor.greenColor()
        //bottomRightButton.backgroundColor = UIColor.whiteColor()
        bottomLeftButton.tintColor = UIColor.greenColor()
        //bottomLeftButton.backgroundColor = UIColor.whiteColor()
        
        
        let gButton = (UIImage(named:"guardButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        let fButton = (UIImage(named:"forwardButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        let xButton = (UIImage(named:"flexButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        let bButton = (UIImage(named:"benchButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        
        
        if(position == "G") {
            if(numBench == 0) {
                bottomRightButton.setImage(bButton, forState: .Normal)
                bottomRightButton.hidden = false
                bottomRightButton.tag = 3
            }
            if(numFlex == 0) {
                bottomLeftButton.hidden = false
                bottomLeftButton.setImage(xButton, forState: .Normal)
                bottomLeftButton.tag = 2
            }
        }
        if(position == "F") {
            if(numBench == 0) {
                bottomRightButton.setImage(bButton, forState: .Normal)
                bottomRightButton.hidden = false
                bottomRightButton.tag = 3
            }
            if(numFlex == 0) {
                bottomLeftButton.setImage(xButton, forState: .Normal)
                bottomLeftButton.hidden = false
                bottomLeftButton.tag = 2
            }
        }
        if(position == "X") {
            if(numBench == 0) {
                bottomRightButton.setImage(bButton, forState: .Normal)
                bottomRightButton.hidden = false
                bottomRightButton.tag = 3
            }
            if(players[index]["position"] as! String == "G") {
                if(numGuards != 2) {
                    bottomLeftButton.setImage(gButton, forState: .Normal)
                    bottomLeftButton.hidden = false
                    bottomLeftButton.tag = 0
                }
            }
            
            if(players[index]["position"] as! String == "F") {
                if(numForwards != 2) {
                    bottomLeftButton.setImage(fButton, forState: .Normal)
                    bottomLeftButton.hidden = false
                    bottomLeftButton.tag = 1
                }
            }
        }
        
        if(position == "B") {
            if(players[index]["position"] as! String == "G") {
                print("numGuards:" + String(numGuards))
                if(numGuards != 2) {
                    bottomLeftButton.setImage(gButton, forState: .Normal)
                    bottomLeftButton.hidden = false
                    bottomLeftButton.tag = 0
                    
                }
                if(numFlex == 0) {
                    bottomRightButton.hidden = false
                    bottomRightButton.setImage(xButton, forState: .Normal)
                    bottomRightButton.tag = 2
                }
            }
            
            if(players[index]["position"] as! String == "F") {
                print(numForwards)
                if(numForwards != 2) {
                    bottomLeftButton.setImage(fButton, forState: .Normal)
                    bottomLeftButton.hidden = false
                    bottomLeftButton.tag = 1
                }
                if(numFlex == 0) {
                    bottomRightButton.setImage(xButton, forState: .Normal)
                    bottomRightButton.hidden = false
                    bottomRightButton.tag = 2
                }
            }
        }
        
        bottomLeftButton.addTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
        bottomRightButton.addTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
    }
    
    func moveOne(sender: UIButton) {
        
        var position = ""
        if(sender.tag == 0) {
            position = "G"
        } else if(sender.tag == 1) {
            position = "F"
        } else if(sender.tag == 2) {
            position = "X"
        } else if(sender.tag == 3) {
            position = "B"
        }
        
        print(position)
        
        let player = players[playerToMove]["id"] as! String
        
        
        var responseString = "" as! NSString
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftmoveoneplayer.php")!)
        request.HTTPMethod = "POST"
        let postString = "player=" + player + "&position=" + position + "&league=" + String(self.league)
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
                self.bottomRightButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
                self.bottomLeftButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
                self.bottomRightButton.hidden = true
                self.bottomLeftButton.hidden = true
                self.moving = false
                self.playerToMove = -1
                self.getPlayers()
            }
            
        }
        task.resume()
    }
    
    
    func here(sender: UIButton) {
        
        if(!onePressed) {
            onePressed = true
            print("!!")
        let player = players[playerToMove]["id"] as! String
        let player2 = players[sender.tag]["id"] as! String
        let currentPos = playerToMove
        let newPos = sender.tag
        
        moving = false
        playerToMove = -1
        
        if(Reachability.isConnectedToNetwork()) {
        
            var responseString = "" as! NSString
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.metrofantasyball.com/swiftmoveplayers.php")!)
            request.HTTPMethod = "POST"
            let postString = "playerOne=" + String(player) + "&league=" + String(self.league) + "&playerTwo=" + String(player2)
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
                    
                    if((responseString as! String).rangeOfString("network connection was lost") == nil) {
                        self.getPlayers()
                        
                        self.bottomRightButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
                        self.bottomLeftButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
                        self.bottomRightButton.hidden = true
                        self.bottomLeftButton.hidden = true
                    } else {
                        let alert = UIAlertController(title: "Oops!", message: "You are no longer connected to the Internet", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) -> Void in
                            
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        self.playersTable.reloadData()
                        self.bottomRightButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
                        self.bottomLeftButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
                        self.bottomRightButton.hidden = true
                        self.bottomLeftButton.hidden = true
                        self.onePressed = false
                    }
                }
                
            }
            task.resume()
        } else {
            
            let alert = UIAlertController(title: "Oops!", message: "You are no longer connected to the Internet", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) -> Void in
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            
            self.playersTable.reloadData()
            self.bottomRightButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
            self.bottomLeftButton.removeTarget(self, action: "moveOne:", forControlEvents: .TouchUpInside)
            self.bottomRightButton.hidden = true
            self.bottomLeftButton.hidden = true
            onePressed = false
            
        }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "addPlayer") {
            let controller = segue.destinationViewController as! AddPlayersViewController
            controller.league = league
            controller.currTeam = team
        }
        if(segue.identifier == "viewStandings") {
            let controller = segue.destinationViewController as! StandingsViewController
            controller.league = league
        }
        if(segue.identifier == "viewOtherTeams") {
            let controller = segue.destinationViewController as! OtherTeamsViewController
            controller.league = league
            controller.team = team
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func move(sender: UIButton) {
        playerToMove = sender.tag
        moving = true
        playersTable.reloadData()
        
        configureBottomButtons(players[sender.tag]["currentPosition"] as! String, index: sender.tag)
    }
    
    
    
    
}
