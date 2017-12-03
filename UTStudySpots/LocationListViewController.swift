//
//  LocationListViewController.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 10/8/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

let textCellIdentifier = "TextCell"


class LocationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, UITabBarDelegate{
    
    
 
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableView: UITableView!
    var favorites:[Int] = []
    var username = ""
    var filteredlocation = [NSManagedObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let nc = NSNotificationCenter.defaultCenter()
        //searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All", "Noise", "Occupancy", "Both"]
        searchController.searchBar.barTintColor = UIColor.blackColor()
        searchController.searchBar.tintColor = UIColor.orangeColor()
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        nc.addObserver(self,
                       selector: #selector(self.updateFav),
                       name: "updatefav",
                       object: nil)
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.objectForKey("username")! as! String
        fetchFavorites()
        tableView.delegate = self
        tableView.dataSource = self
        self.definesPresentationContext = true
        
        
     
        self.automaticallyAdjustsScrollViewInsets = false
        //FavoritesViewController.searchController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewDidLayoutSubviews() {
        self.searchController.searchBar.sizeToFit()
    }
    // Called when the user touches on the main view (outside the UITextField).
    //
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        searchController.active = false
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
        if searchController.active && (searchController.searchBar.selectedScopeButtonIndex != 0 || searchController.searchBar.text != "") {
            return filteredlocation.count
        }
        return retrieveLocs().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
        let utlocation:NSManagedObject
        if searchController.active && (searchController.searchBar.selectedScopeButtonIndex != 0 || searchController.searchBar.text != "") {
            utlocation = filteredlocation[indexPath.row]
        } else {
            let row = indexPath.row
            let results = retrieveLocs()
            utlocation = results[row]
            
        }
        let name = utlocation.valueForKey("name")
        let acro = utlocation.valueForKey("acronym")
        let fullName:String? = "\(name!) (\(acro!))"
        cell.textLabel?.text = fullName
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 0.0)
        cell.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 0.0)
        //cell.layer.borderColor = UIColor.orangeColor().CGColor
        //cell.layer.borderWidth = 2.0
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print(row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newLocSegue" {
            if let vc = segue.destinationViewController as? AddLocationViewController {
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            }
        }
        
        if  segue.identifier == "buildingSegue",
            let vc = segue.destinationViewController as? DisplayRatingsViewController,
            index = tableView.indexPathForSelectedRow?.row {
            let utlocation: NSManagedObject
            if searchController.active && (searchController.searchBar.selectedScopeButtonIndex != 0 || searchController.searchBar.text != "") {
                utlocation = filteredlocation[index]
            } else {
                utlocation = retrieveLocs()[index]
            }
            vc.location = utlocation
            vc.hidesBottomBarWhenPushed = true
            if favorites.contains(utlocation.valueForKey("id")! as! Int){
                vc.isFavorite = true
            }
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
                print(value["favorites"]!)
                self.favorites = []
                for fave in value["favorites"]! as! [Int] {
                    self.favorites.append(fave)
                }
                self.tableView.reloadData()
                
                
        }
    }
    func fetchSort(sortby: String, searchText: String) {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/sort",
            parameters: ["include_docs": "true", "sortby" : sortby],
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
                print(value["locations"]!)
                self.filteredlocation = []
                for location in value["locations"]! as! [AnyObject] {
                    let id = location["_id"] as! Int
                    self.filteredlocation.append(self.retrieveLocs()[id-1])
                }
                print("before filter")
                if(searchText != "") {
                    self.filteredlocation = self.filteredlocation.filter { location in
                        return location.valueForKey("name")!.lowercaseString.containsString(searchText.lowercaseString) || location.valueForKey("acronym")!.lowercaseString.containsString(searchText.lowercaseString)
                    }
                }
                print(self.filteredlocation)
                print("done")
                self.tableView.reloadData()
                
                
        }
    }
    func updateFav() {
        print("favorites changed")
        fetchFavorites()
    }
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        if(scope == "Noise" || scope == "Occupancy" || scope == "Both"){
            print("hear")
            fetchSort(scope , searchText: searchText)
            
        } else{
            
            filteredlocation = retrieveLocs().filter { location in
                return location.valueForKey("name")!.lowercaseString.containsString(searchText.lowercaseString) || location.valueForKey("acronym")!.lowercaseString.containsString(searchText.lowercaseString)
            }
        
            tableView.reloadData()
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
extension LocationListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}
extension LocationListViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("this get called")
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

