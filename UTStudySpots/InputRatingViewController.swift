//
//  InputRatingViewController.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 10/8/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import Alamofire
protocol UpdatedData{
    func notify(mess:String)
}
class InputRatingViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate   {
    @IBOutlet weak var noiseLevelSegment: UISegmentedControl!
    @IBOutlet weak var occupancyLevelSegment: UISegmentedControl!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var saveLabel: UILabel!
    
    var getNoiseSegment:Int?
    var getOccupancySegment:Int?
    var commentText:String?
    var floorId = 0
    var fullname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        fullname = defaults.objectForKey("firstname")! as! String + " " + (defaults.objectForKey("lastname")! as! String)
        comment.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        getNoiseSegment = noiseLevelSegment.selectedSegmentIndex
        getOccupancySegment = occupancyLevelSegment.selectedSegmentIndex
        commentText = comment.text!
        
        saveLabel.text! = "Data saved!"
        
        enterInput()
        
        //print("noise = \(getNoiseSegment) occupancy = \(getOccupancySegment) comment = \(commentText)")
        dismissViewControllerAnimated(true, completion:nil)
    }
    var delegate: UpdatedData?
    func datasaved(mess:String){
        if let del = delegate{
            del.notify(mess)
        }
        
    }
    
    func enterInput() {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/updateFloor",
            parameters: ["include_docs": "true", "noiseRate": getNoiseSegment!, "occupancyRate": getOccupancySegment!, "id": floorId, "comment": commentText!, "user": fullname],
            encoding: .URL)
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Error while fetching register: \(response.result.error)")
                    return
                }
                
                guard let value = response.result.value as? [String: AnyObject]
                    else {
                        print("didn't get anything")
                        return
                }
                print(value["success"]!)
                self.datasaved("Data Saved and Calculated")
        }
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    let COMMENTS_LIMIT = 150
    func textView(textView: UITextView, shouldChangeTextInRange range:NSRange, replacementText text:String ) -> Bool {
        print (comment.text!.characters.count + (text.characters.count - range.length))
        return comment.text!.characters.count + (text.characters.count - range.length) <= COMMENTS_LIMIT;
        
    }
    // Called when the user touches on the main view (outside the UITextField).
    //
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
