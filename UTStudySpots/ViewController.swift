//
//  ViewController.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 10/8/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Foundation

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginLabel: UILabel!
    var loginsuccess = false
    
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        super.viewDidLoad()
        passwordText.secureTextEntry = true
        
        saveLocs()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "registerSegue" {
            if let vc = segue.destinationViewController as? RegisterViewController {
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        fetchlogin()
    }

    func fetchlogin() {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/login",
            parameters: ["include_docs": "true", "email" : usernameText.text!, "password" : passwordText.text!],
            encoding: .URL)
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Error while fetching login: \(response.result.error)")
                    return
                }
                
                guard let value = response.result.value as? [String: AnyObject]
                    else {
                        print("didn't get anything")
                        return
                }
                self.loginsuccess = value["success"]! as! String == "YES"
                if (self.loginsuccess){
                    self.storeLoginInfo(value["firstname"]! as! String, lastName: value["lastname"]! as! String)
                    
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                    
                } else{
                    self.loginLabel.text = "Invalid Email or password"
                }
                
                print(value["success"]!)
        }

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
    
    //-----------------
    // Core Data Stuff
    //-----------------
    
    func saveLocs(){
        print("saveLocation")
        //clearCoreData()
        let place1 = ["id" : 1, "placeName" : "Student Activity Center", "acronym" : "SAC", "floors" : 3, "desc" : "", "lat": 30.284902, "long": -97.736039]
        let place2 = ["id" : 2, "placeName" : "Flawn Academic Center", "acronym" : "FAC", "floors" : 6, "desc" : "", "lat": 30.286270, "long": -97.740298]
        let place3 = ["id" : 3, "placeName" : "Perry-Castaneda Library", "acronym" : "PCL", "floors" : 6, "desc" : "", "lat": 30.28240, "long": -97.73788]
        let place4 = ["id" : 4, "placeName" : "Union Building", "acronym": "UNB", "floors" : 5, "desc" : "", "lat": 30.286560, "long": -97.741186]
        let place5 = ["id" : 5, "placeName" : "Gates Dell Complex", "acronym" : "GDC", "floors" : 7, "desc" : "", "lat": 30.286227, "long": -97.736605]
        let place6 = ["id" : 6, "placeName" : "Robert Lee Moore Hall", "acronym" : "RLM", "floors" : 10, "desc" : "", "lat": 30.28892, "long": -97.73634]
        let place7 = ["id" : 7, "placeName" : "Liberal Arts Building", "acronym" : "CLA", "floors" : 5, "desc" : "", "lat": 30.284921, "long": -97.735461]
        let place8 = ["id" : 8, "placeName" : "Robert A. Welch Hall", "acronym" : "WEL", "floors" : 7, "desc" : "", "lat": 30.28656, "long": -97.73783]
        let place9 = ["id" : 9, "placeName" : "Norman Hackerman Building", "acronym" : "NHB", "floors" : 9, "desc" : "", "lat": 30.287639, "long": -97.738017]
        let place10 = ["id" : 10, "placeName" : "Student Services Building", "acronym" : "SSB", "floors" : 6, "desc" : "", "lat": 30.29017, "long": -97.73850]

        
        
        let places = [place1,place2,place3,place4,place5,place6,place7,place8,place9,place10]
        
        // Check/update all locations in coreData
        let retrievedData = retrieveLocs()
        
        if retrievedData.count != 10{
            clearCoreData()
        }
        if retrievedData.count == 0{
            for location in places{
                storeLoc(location)
            }
        }
        else {
            for location in retrievedData{
                print (location.valueForKey("name"), location.valueForKey("lat"), location.valueForKey("long"))
            }
            print("data already exists")
        }
 
    }
    
    func storeLoc(location:[String:AnyObject]){
        print("storelocation")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        
        // Create the entity we want to save
        let entity =  NSEntityDescription.entityForName("UTPlace", inManagedObjectContext: managedContext)
        let places = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        // Set the attribute values
        places.setValue(location["id"], forKey: "id")
        places.setValue(location["placeName"], forKey: "name")
        places.setValue(location["acronym"], forKey: "acronym")
        places.setValue(location["floors"], forKey: "floors")
        places.setValue(location["desc"], forKey: "desc")
        places.setValue(location["lat"], forKey: "lat")
        places.setValue(location["long"], forKey: "long")
        
        do {
            print("saving to core")
            try managedContext.save()
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        print("end")
        let retrieved = retrieveLocs()
        for place in retrieved {
            if let name = place.valueForKey("name") {
                if let acronym = place.valueForKey("acronym") {
                    print("Name: \(name), Acronym: \(acronym)")
                }
            }
        }
        
    }

    func clearCoreData() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "UTPlace")
        var fetchedResults:[NSManagedObject]
        
        do {
            try fetchedResults = managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                
                for result:AnyObject in fetchedResults {
                    managedContext.deleteObject(result as! NSManagedObject)
                    print("\(result.valueForKey("name")!) has been Deleted")
                }
            }
            try managedContext.save()
            
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
    }
    
    func retrieveLocs() -> [NSManagedObject] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName:"UTPlace")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults)!
    }
    func storeLoginInfo(firstName:String, lastName:String){
    
        let kUserNameKey = "username"
        let kPassword = "password"
        let kfirstName = "firstname"
        let klastName = "lastname"
        let username = usernameText.text!
        let password = passwordText.text!

        // Get a reference to the global user defaults object
        let defaults = NSUserDefaults.standardUserDefaults()
        // Store various values
        defaults.setObject(username, forKey: kUserNameKey)
        defaults.setObject(password, forKey: kPassword)
        defaults.setObject(firstName, forKey: kfirstName)
        defaults.setObject(lastName, forKey: klastName)
       
    }

}

