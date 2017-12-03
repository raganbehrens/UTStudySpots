//
//  FloorLevelViewController.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 10/18/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import Foundation

protocol UpdatedDataPlace{
    func notify(mess:String)
}
class FloorLevelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdatedData {

    @IBOutlet weak var floorLvl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noiseCounterView: CounterView!
    @IBOutlet weak var occupancyCounterView: CounterView!
    @IBOutlet weak var noiseLvl: UILabel!
    @IBOutlet weak var occupancyLvl: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!
    var comments = ["no comments"]
    var comments2: [AnyObject] = []
    var floorName = 0
    var building = String()
    var location: NSManagedObject! = nil
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), forControlEvents: .ValueChanged)
        scrollView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        floorLvl.text! = "\(location.valueForKey("name")!) Floor Level: \(floorName)"
        fetchRatings()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        let pics = ["PCL","SAC", "UNB"]
        if pics.contains(location.valueForKey("acronym")! as! String) {
            imageView.image = UIImage(named: "\(location.valueForKey("acronym")!)\(floorName)")
        } else {
            imageView.image = UIImage(named:"\(location.valueForKey("acronym")!)")
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments2.count==0{
            return comments.count
        }
        return comments2.count
    }
    func didPullToRefresh(){
        print("We got refresh")
        fetchRatings()
        datasaved("Refreshing")
        
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath)
        
        let row = indexPath.row
        if comments2.count == 0 {
            cell.textLabel?.text = comments[row]
            cell.detailTextLabel?.text = ("")
        }
        else{
            cell.textLabel?.text = (comments2[row]["message"] as? String)!
            cell.detailTextLabel?.text = (comments2[row]["user"] as? String)! + " " + (comments2[row]["date"] as? String)!
            cell.textLabel?.textColor = UIColor.orangeColor()
            cell.layer.borderColor = UIColor.orangeColor().CGColor
            cell.layer.borderWidth = 2.0
            cell.textLabel?.numberOfLines = 0

            //cell.textLabel?.lineBreakMode = UILineBreakModeWordWrap
        }
        
        
        cell.textLabel?.textColor = UIColor.orangeColor()
        
        return cell
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "enterRatingSegue" {
            if let vc = segue.destinationViewController as? InputRatingViewController {
              vc.floorId = floorId
                vc.delegate = self
                
                
            }
        }
        /*else if segue.identifier == "loginSegue" {
         if let vc = segue.destinationViewController as? LocationListViewController {
         
         }
         }*/
    }
    var delegate: UpdatedDataPlace?
    func datasaved(mess:String){
        if let del = delegate{
            del.notify(mess)
        }
        
    }
    func notify(mess: String) {
        print(mess)
        fetchRatings()
        datasaved("Data calculated and saved")
        
    }
    
    func mySetNoiseRating(avg:Double) {
        noiseCounterView.counter = avg
        noiseLvl.text = String(format: "%.1f", avg)
    }
    func mySetOccupancyRating(avg:Double) {
        occupancyCounterView.counter = avg
        occupancyLvl.text = String(format: "%.1f", avg)
    }
    
    var floorId = 0
    func fetchRatings() {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/floor",
            parameters: ["include_docs": "true", "locationName": location.valueForKey("name")! as! String, "floorLevel": floorName],
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
                print(value["comments"]!)
                print(value["averageNoise"]!)
                print(value["averageOccupation"]!)
                self.comments2 = []
                //print(value["comments"]![0]["date"])
                for comment in  value["comments"]! as! [AnyObject]{
                    self.comments2.append(comment)
                }
                self.floorId = Int(value["_id"]! as! NSNumber)
                
                let avgNoise = value["averageNoise"] as! float_t
                let avgOccupancy = value["averageOccupation"] as! float_t
                self.mySetNoiseRating(Double(avgNoise))
                self.mySetOccupancyRating(Double(avgOccupancy))
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
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
