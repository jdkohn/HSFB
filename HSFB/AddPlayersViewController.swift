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
    
    @IBOutlet weak var addTable: UITableView
    
    var freeAgents = [NSDictionary]()
    var team = [NSDictionary]()
    
    var playerToAdd = Int()
    
    var adding = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
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
        
        if(adding) {
            cell.nameLabel.text = freeAgents[indexPath.row]["name"] as! String + ", " + freeAgents[indexPath.row]["position"] as! String
            cell.pointsLabel.text = freeAgents[indexPath.row]["fppg"] as! String
            let addButton = (UIImage(named:"plusButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
            cell.addButton.setImage(addButton, forState: .Normal)
            cell.addButton.tag = freeAgents[indexPath.row]["id"] as! Int
            cell.addButton.addTarget(self, action: "addPlayer:", forControlEvents: .TouchUpInside)
        } else {
            cell.nameLabel.text = team[indexPath.row]["name"] as! String + ", " + team[indexPath.row]["position"] as! String
            cell.pointsLabel.text = team[indexPath.row]["fppg"] as! String
            let dropButton = (UIImage(named:"dropButton.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
            cell.addButton.setImage(dropButton, forState: .Normal)
            cell.addButton.tag = team[indexPath.row]["id"] as! Int
            cell.addButton.addTarget(self, action: "dropPlayer:", forControlEvents: .TouchUpInside)
        }
        return cell
    }
    
    func addPlayer(sender: UIButton) {
        playerToAdd = sender.tag
        adding = false
        addTable.reloadData()
        
    }
    
    func dropPlayer(sender: UIButton) {
        
    }
    
    
}

