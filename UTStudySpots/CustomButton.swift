//
//  CustomButton.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 11/21/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import Foundation

class CustomButton: UIButton {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = UIColor.orangeColor().CGColor
        self.layer.borderWidth = 1.5
        self.backgroundColor = UIColor.whiteColor()
        self.tintColor = UIColor.whiteColor()
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
        layer.shadowOffset = CGSize(width: 0, height: 3);
        layer.shadowOpacity = 1.0
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
