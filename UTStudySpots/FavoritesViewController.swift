//
//  FavoritesViewController.swift
//  UTStudySpots
//
//  Created by Jorge Munoz on 11/1/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var searchController:UISearchController!
    var username = ""
    let nofav = ["No Favorites"]
    var favorites:[Int] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Get a reference to the global user defaults object
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.objectForKey("username")! as! String
        print(username)
        fetchFavorites()
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self,
                       selector: #selector(self.updateData),
                       name: "updateTable",
                       object: nil)
        //searchController.active = false
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(animated: Bool) {
//        navigationController?.navigationBarHidden = false
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favorites.count == 0{
            return 1
        }
        return favorites.count
    }
    
    // Place this code in the VC for the table.
    //
    // This example makes the first element in the table (row = 0) unelectable,
    // and every other row selectable.
    
    func tableView(tableView: UITableView,
                   willSelectRowAtIndexPath indexPath: NSIndexPath)
        -> NSIndexPath? {
            if favorites.count == 0 {
                return indexPath.row == 0 ? nil : indexPath
            }
            return indexPath
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favorites", forIndexPath: indexPath)
        
        let row = indexPath.row
        if favorites.count == 0 {
            cell.textLabel?.text = nofav[row]
        }
        else{
            let results = retrieveLocs()
            let utlocation = results[favorites[row]-1]
            let name = utlocation.valueForKey("name")
            let acro = utlocation.valueForKey("acronym")
            let fullName:String? = "\(name!) (\(acro!))"
            cell.textLabel?.text = fullName
        }
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 0.0)
        cell.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 0.0)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print(row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "favsSegue",
            let vc = segue.destinationViewController as? DisplayRatingsViewController,
            index = tableView.indexPathForSelectedRow?.row {
            vc.location = retrieveLocs()[favorites[index]-1]
            vc.isFavorite = true
        }
    }
    func fetchFavorites() {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/getFavorites",
            parameters: ["include_docs": "true", "username" : username],
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
                self.favorites = []
                print(value["favorites"]!)
                for fave in value["favorites"]! as! [Int] {
                    self.favorites.append(fave)
                }
                self.tableView.reloadData()
                
                
        }
    }
    
    func updateData() {
        print("favorites changed")
        fetchFavorites()
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
