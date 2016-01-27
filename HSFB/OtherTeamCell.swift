//
//  OtherTeamCell.swift
//  HSFB
//
//  Created by Jacob Kohn on 1/27/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class OtherTeamCell: UITableViewCell {
    
    @IBOutlet weak var p7: UILabel!
    @IBOutlet weak var p6: UILabel!
    @IBOutlet weak var p5: UILabel!
    @IBOutlet weak var p4: UILabel!
    @IBOutlet weak var p3: UILabel!
    @IBOutlet weak var p2: UILabel!
    @IBOutlet weak var p1: UILabel!
    @IBOutlet weak var owner: UILabel!
    @IBOutlet weak var team: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}