//
//  AddLocationViewController.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 11/14/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import Alamofire

class AddLocationViewController: UIViewController {
    @IBOutlet weak var buildingName: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var dataSaved: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSaved.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveButton(sender: AnyObject) {
        if(buildingName.text! == "" || address.text! == "" || desc.text! == ""){
            
            dataSaved.text = "Please fill in Everything"
        } else {
            enternewLocation()
        }
    }
    
    func notify(message:String, button1: String, button2: String){
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        
        dispatch_async(backgroundQueue) {
            let controller = UIAlertController(title: "Save", message: message, preferredStyle: .Alert)
            let secondButton = UIAlertAction(title: button2, style: .Cancel){
                UIAlertAction in
                //self.storeLoginInfo(self.firstNameText.text!, lastName: self.lastNameText.text!)
                //self.performSegueWithIdentifier("registeredSegue", sender: self)
            }
            if (button2 != ""){
                controller.addAction(secondButton)
            }
            controller.addAction(UIAlertAction(title: button1 ,style: .Default, handler: nil))
            
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(controller, animated: true, completion: nil)
                
            }
        }
        
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    func enternewLocation() {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/addLocation",
            parameters: ["include_docs": "true", "name": buildingName.text!, "address": address.text!, "description": desc.text!],
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
                self.notify("Location has been sent programmers will Review your request", button1: "OK", button2: "")
                self.dataSaved.text = "Data has been saved"
                //self.datasaved("Data Saved and Calculated")
        }
    }
    

}
