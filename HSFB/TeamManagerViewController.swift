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
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var standingsButton: UIButton!
    
    var players = [NSDictionary]()
    var league = Int()
    var team = Int()
    var user = Int()
    var teamName = String()
    
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
    
    moving = false
    playerToMove = -1
    
    //getPlayers()
    
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
    self.parsePlayers(responseString as! String)
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
    
    for(var i=0; i<g.count; i++) {
    temp.append(players[g[i]])
    }
    for(var i=0; i<f.count; i++) {
    temp.append(players[f[i]])
    }
    for(var i=0; i<x.count; i++) {
    temp.append(players[x[i]])
    }
    for(var i=0; i<b.count; i++) {
    temp.append(players[b[i]])
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
    if(playerToMove <= 1) {
    if(indexPath.row <= 3) {
    cell.moveButton.hidden = true
} else if(indexPath.row <= 6) {
    cell.moveButton.backgroundColor = UIColor.redColor()
    cell.moveButton.setTitle("Here", forState: .Normal)
    cell.moveButton.tag = indexPath.row
    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
    }
} else if(playerToMove <= 3) {
    if(indexPath.row <= 3) {
    cell.moveButton.hidden = true
} else if(indexPath.row <= 6) {
    cell.moveButton.backgroundColor = UIColor.redColor()
    cell.moveButton.setTitle("Here", forState: .Normal)
    cell.moveButton.tag = indexPath.row
    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
    }
} else if(playerToMove == 4) {
    if((players[4]["position"] as! String) == "G") {
    if(indexPath.row <= 1) {
    cell.moveButton.backgroundColor = UIColor.redColor()
    cell.moveButton.setTitle("Here", forState: .Normal)
    cell.moveButton.tag = indexPath.row
    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
} else if(indexPath.row <= 4) {
    cell.moveButton.hidden = true
} else if(indexPath.row <= 6) {
    cell.moveButton.backgroundColor = UIColor.redColor()
    cell.moveButton.setTitle("Here", forState: .Normal)
    cell.moveButton.tag = indexPath.row
    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
    }
} else {
    if(indexPath.row <= 1) {
    cell.moveButton.hidden = true
} else if(indexPath.row <= 3) {
    cell.moveButton.backgroundColor = UIColor.redColor()
    cell.moveButton.setTitle("Here", forState: .Normal)
    cell.moveButton.tag = indexPath.row
    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
} else if(indexPath.row == 4) {
    cell.moveButton.hidden = true
} else if(indexPath.row <= 6) {
    cell.moveButton.backgroundColor = UIColor.redColor()
    cell.moveButton.setTitle("Here", forState: .Normal)
    cell.moveButton.tag = indexPath.row
    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
    }
    }
} else if(playerToMove <= 6) {
    if((players[playerToMove]["position"] as! String) == "G") {
    if(indexPath.row <= 1) {
    cell.moveButton.backgroundColor = UIColor.redColor()
    cell.moveButton.setTitle("Here", forState: .Normal)
    cell.moveButton.tag = indexPath.row
    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
} else if(indexPath.row <= 3) {
    cell.moveButton.hidden = true
} else if(indexPath.row == 4) {
    cell.moveButton.backgroundColor = UIColor.redColor()
    cell.moveButton.setTitle("Here", forState: .Normal)
    cell.moveButton.tag = indexPath.row
    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
} else if(indexPath.row <= 6) {
    cell.moveButton.hidden = true
    }
} else {
    if(indexPath.row <= 1) {
    cell.moveButton.hidden = true
} else if(indexPath.row <= 4) {
    cell.moveButton.backgroundColor = UIColor.redColor()
    cell.moveButton.setTitle("Here", forState: .Normal)
    cell.moveButton.tag = indexPath.row
    cell.moveButton.addTarget(self, action: "here:", forControlEvents: .TouchUpInside)
} else if(indexPath.row <= 6) {
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
    playersTable.reloadData()
    }
    
    func here(sender: UIButton) {
    
    let player = players[playerToMove]["id"] as! String
    let player2 = players[sender.tag]["id"] as! String
    let currentPos = playerToMove
    let newPos = sender.tag
    
    
    print("playerOne=" + String(player) + "&league=" + String(self.league) + "&playerTwo=" + String(player2))
    
    
    moving = false
    playerToMove = -1
    
    
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
    self.getPlayers()
    }
    
    }
    task.resume()
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
    }
    
    
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
    
    
    func move(sender: UIButton) {
    playerToMove = sender.tag
    moving = true
    playersTable.reloadData()
    
    print("!" + String(sender.tag))
    }
    
    
    
    
}
