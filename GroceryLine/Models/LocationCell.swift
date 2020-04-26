//
//  LocationCell.swift
//  GroceryLine
//
//  Created by Andre Assadi on 4/25/20.
//  Copyright © 2020 AndreAssadiProjects. All rights reserved.
//

import Foundation
import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var waitTime: UILabel!
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var actualWaitTime: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Init Code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // configure view for selected state
        
    }
    
    
}
