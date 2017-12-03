//
//  SplashPageViewController.swift
//  UTStudySpots
//
//  Created by Jorge Munoz on 10/31/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit

class SplashPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBackgroundImage()
        
        _ = NSTimer.scheduledTimerWithTimeInterval(
            2.5, target: self, selector: #selector(SplashPageViewController.show), userInfo: nil, repeats: false
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden()->Bool {
    return true
    }
    
    func show() {
        self.performSegueWithIdentifier("showApp", sender: self)
    }
    
    
    func addBackgroundImage() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let bg = UIImage(named: "Default.png")
        let bgView = UIImageView(image: bg)
        
        bgView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        self.view.addSubview(bgView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
