//
//  CardView.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 11/20/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit

@IBDesignable class CardView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 3.0
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.orangeColor()
    @IBInspectable var shadowOpacity: Float = 0.8
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.CGPath
        
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
