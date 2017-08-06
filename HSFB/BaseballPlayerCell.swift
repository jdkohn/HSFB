//
//  BaseballPlayerCell.swift
//  HSFB
//
//  Created by Jacob Kohn on 3/9/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class BaseballPlayerCell: UITableViewCell {
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}