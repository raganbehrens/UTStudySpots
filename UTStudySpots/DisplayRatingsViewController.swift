//
//  DisplayRatingsViewController.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 10/8/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import CoreData
import Alamofire




class DisplayRatingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdatedDataPlace {

    @IBOutlet weak var buildingName: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var noiseRating: UILabel!
    @IBOutlet weak var occupancyRating: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var counterView: CounterView!
    @IBOutlet weak var occupancyCounterView: CounterView!
    
    var location: NSManagedObject! = nil
    var noiseLevel:Int?
    var occupancyLevel:Int?
    var locName = ""
    var username = ""
    var isFavorite = false
    var count = 0
    @IBOutlet weak var scrollView: UIScrollView!
    let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = UIModalPresentationStyle.FullScreen

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = false
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), forControlEvents: .ValueChanged)
        scrollView.addSubview(refreshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print(location)
        let name = location.valueForKey("name")! as! String
        let acro = location.valueForKey("acronym")
        locName = "\(name) (\(acro!))"
        print("location name = \(locName)")
        buildingName.adjustsFontSizeToFitWidth = true
        buildingName.text! = locName
        
        // Get a reference to the global user defaults object
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.objectForKey("username")! as! String
        if isFavorite == true {
            let image = UIImage(named: "highlighted_star")
            favButton.setImage(image, forState: UIControlState.Normal)
            count = 1
        }
        setPic()
        fetchRatings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favoriteButton(sender: AnyObject) {
        if count == 0 {
            let image = UIImage(named: "highlighted_star")
            favButton.setImage(image, forState: UIControlState.Normal)
            count = 1
            addFavorites()
        } else{
            let image = UIImage(named: "star")
            favButton.setImage(image, forState: UIControlState.Normal)
            count = 0
            unFavorite()
        }
    }
    func didPullToRefresh(){
        print("We got refresh")
        fetchRatings()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numOfFloor:Int = Int(location.valueForKey("floors")! as! NSNumber)
        return numOfFloor
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
        
        let row = indexPath.row
        print ("we are at row \(row)")
        cell.textLabel?.text = ("Floor Level \(row+1)")
        cell.textLabel?.textColor = UIColor.whiteColor()
//        cell.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 0.0)
        cell.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 0.0)
        
        /*if (row != 0 && row != (location.valueForKey("floors")! as! Int) - 1){
            cell.layer.borderColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0).CGColor
            cell.layer.borderWidth = 9.0
            cell.layer.cornerRadius = 3.0
        }*/

        //tableView.layer.borderColor = UIColor.orangeColor().CGColor
        //tableView.layer.borderWidth = 2.0
        
        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print(row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "floorLvlSegue",
            let vc = segue.destinationViewController as? FloorLevelViewController,
            index = tableView.indexPathForSelectedRow?.row {
            vc.location = location
            vc.floorName = index+1
            vc.delegate = self
        }
    }
    
    func setPic() {
        
//        descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        descriptionLabel.numberOfLines = 3
        
        if locName == "Student Activity Center (SAC)" {
            imageView.image = UIImage(named: "SAC")
            descriptionLabel.text = "The SAC is located in the middle of campus. It has a 5,000-SF ballroom, a 500-seat auditorium, a black box theater, twelve conference/meeting rooms, and outdoor gathering spaces are all available for clubs and student organizations. Has a Starbucks."
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 6
        }
        else if locName == "Flawn Academic Center (FAC)" {
                imageView.image = UIImage(named: "FAC")
                descriptionLabel.text = "The FAC is located in right next to the UT Tower. It is an undergraduate library and technology and collaboration facility. Contains coffee machine"
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 4
        }
        else if locName == "Perry-Castaneda Library (PCL)" {
            imageView.image = UIImage(named: "PCL")
            descriptionLabel.text = "The PCL is the main central library of the University of Texas at Austin library system. Open 24/7 During finals. Has coffee."
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 3
        }
        else if locName == "Union Building (UNB)" {
            imageView.image = UIImage(named: "UNB")
            descriptionLabel.text = "The Union is located right next to the FAC. It serves as a college independent community center or living room for students. Has a Starbucks"
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 4
        }
        else if locName == "Gates Dell Complex (GDC)" {
            imageView.image = UIImage(named: "GDC")
            descriptionLabel.text = "The GDC is located in the middle of campus. Home to great Computer Science majors. Beware of them. Coffee stand available."
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 3
        }
        else if locName == "Robert Lee Moore Hall (RLM)" {
            imageView.image = UIImage(named: "RLM")
            descriptionLabel.text = "The RLM is located in corner of Speedway and Dean Keeton. This building has coffee and watching the star party on wednesday night."
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 3
        }
        else if locName == "Liberal Arts Building (CLA)" {
            imageView.image = UIImage(named: "CLA")
            descriptionLabel.text = "The CLA is located in the middle of campus behind the SAC. Home of the liberal students. Classrooms and other gathering spaces maximize student and faculty collaboration while minimizing environmental impacts."
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 5
        }
        else if locName == "Norman Hackerman Building (NHB)" {
            imageView.image = UIImage(named: "NHB")
            descriptionLabel.text = "The NHB is located on E 24th. This provides space for an integrated and interdisciplinary approach to education."
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 3
        }
        else if locName == "Student Services Building (SSB)" {
            imageView.image = UIImage(named: "SSB")
            descriptionLabel.text = "The SSB is located right on Dean Keeton. You can go see the doctor. Registrar office. Reserve office. And you can buy coffee."
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 3
        }
        else if locName == "Robert A. Welch Hall (WEL)" {
            imageView.image = UIImage(named: "WEL")
            descriptionLabel.text = "The WEL is located in the middle of campus right next to Greg Gym. Has a microwave. You'll most likely have chem class in there."
            descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            descriptionLabel.numberOfLines = 3
        }
        
    }

    
    func mySetNoiseRating(avg:Double) {
        counterView.counter = avg
        noiseRating.text = String(format: "%.1f", avg)
    }
    func mySetOccupancyRating(avg:Double) {
        occupancyCounterView.counter = avg
        occupancyRating.text = String(format: "%.1f", avg)
    }
    
    func notify(mess: String) {
        print(mess)
        fetchRatings()
    }
    
    func fetchRatings() {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/place",
            parameters: ["include_docs": "true", "id": Int(location.valueForKey("id")! as! NSNumber)],
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
                print(value["averageNoise"]!)
                print(value["averageOccupation"]!)
                let avgNoise = value["averageNoise"] as! float_t
                let avgOccupancy = value["averageOccupation"] as! float_t
                self.mySetNoiseRating(Double(avgNoise))
                self.mySetOccupancyRating(Double(avgOccupancy))
                self.refreshControl.endRefreshing()
        }
    }
    
    func addFavorites() {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/addFavorite",
            parameters: ["include_docs": "true", "id": Int(location.valueForKey("id")! as! NSNumber), "username" : username],
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
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName("updateTable",
                    object: nil)
               
                nc.postNotificationName("updatefav",
                    object: nil)
        }
    }
    
    func unFavorite() {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/unFavorite",
            parameters: ["include_docs": "true", "id": Int(location.valueForKey("id")! as! NSNumber), "username" : username],
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
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName("updateTable",
                    object: nil)
                nc.postNotificationName("updatefav",
                    object: nil)
                
        }
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
