//
//  CounterView.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 11/19/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit

let ratings = 9
let π:CGFloat = CGFloat(M_PI)

@IBDesignable class CounterView: UIView {

    @IBInspectable var counter: Double = 0 {
        didSet {
            //if counter <=  ratings {       // only up to max # of glasses
                //the view needs to be refreshed
                setNeedsDisplay()
            //}
        }
    }
    
    @IBInspectable var outlineColor: UIColor = UIColor.blackColor()
    @IBInspectable var fillColor: UIColor = UIColor.lightGrayColor()
    
    
    override func drawRect(rect: CGRect) {
        
        // ********** CREATE THE ARC BACKGROUND **********
        let center = CGPoint(x:150/2, y: 150/2)
        let radius: CGFloat = max(150, 150)
        
        // Set the thickness of the arc
        let arcWidth: CGFloat = 50
        
        let startAngle: CGFloat = 3 * π / 4
        let endAngle: CGFloat = π / 4
                
        // ********** DRAW OUTLINE OF ARC **********
        
        // Calculate the difference between the two angles,
        // ensuring it is positive
        let angleDifference: CGFloat = 2 * π - startAngle + endAngle
        
        // Calculate the arc for each single glass
        let arcLengthPerGlass = angleDifference / CGFloat(ratings)
        
        // Multiply out by the actual glasses drunk
        let outlineEndAngle = arcLengthPerGlass * CGFloat(counter) + startAngle
        
        let fillPath = UIBezierPath(arcCenter: center,
                                radius: radius/2 - arcWidth/2,
                                startAngle: startAngle,
                                endAngle: outlineEndAngle,
                                clockwise: true)
        
        if counter >= 0 && counter < 4 {
            fillColor = UIColor.greenColor()
        }
        else if counter >= 4 && counter < 7 {
            fillColor = UIColor.yellowColor()
        }
       
        else {
            self.fillColor = UIColor.redColor()
        }
        fillColor.setStroke()
        fillPath.lineWidth = arcWidth
        fillPath.stroke()
        
        for i in 1...9{
        let outlinePath = UIBezierPath(arcCenter: center,
                                       radius: bounds.width/2 - 1.25,
                                       startAngle: startAngle,
                                       endAngle: startAngle + (arcLengthPerGlass*CGFloat(i)),
                                       clockwise: true)
        
        // Draw the inner arc
        outlinePath.addArcWithCenter(center,
                                     radius: bounds.width/2 - arcWidth + 1.25,
                                     startAngle: startAngle + (arcLengthPerGlass*CGFloat(i)),
                                     endAngle: startAngle,
                                     clockwise: false)
        
        // Close the path and draw it
        outlinePath.closePath()
        outlineColor.setStroke()
        outlinePath.lineWidth = 2.5
        outlinePath.stroke()
        }
        
    }
    
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
