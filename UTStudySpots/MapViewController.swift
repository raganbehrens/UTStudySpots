//
//  MapViewController.swift
//  UTStudySpots
//
//  Created by Karla Reyes on 11/12/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Alamofire

var location = ["SAC": 0, "FAC": 1, "PCL": 2, "UNB": 3, "GDC": 4, "RLM": 5, "CLA": 6, "WEL": 7, "NHB": 8, "SSB": 9]
var location2 = [0 : "SAC", 1: "FAC", 2: "PCL", 3: "UNB", 4: "GDC", 5: "RLM", 6: "CLA", 7: "WEL", 8: "NHB", 9: "SSB"]
class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var favorites:[Int] = []
    var username = ""
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        let loc = CLLocation(latitude: 30.28565 , longitude: -97.73921)
        centerMap(loc)
        fetchFavorites()
        dropPins()
        mapView.delegate = self
        locationManager.delegate = self
        // Do any additional setup after loading the view.
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self,
                       selector: #selector(self.updateFav),
                       name: "updatefav",
                       object: nil)
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.objectForKey("username")! as! String
        let CLAuthStatus = CLLocationManager.authorizationStatus()
        if CLAuthStatus == CLAuthorizationStatus.NotDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        self.mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        self.definesPresentationContext = true
        
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMap(location: CLLocation){
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func dropPins(){
        let locations = retrieveLocs()
        for location in locations{
            let latitude = location.valueForKey("lat") as! CLLocationDegrees
            let longitude = location.valueForKey("long") as! CLLocationDegrees
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let annotation = MKPointAnnotation()
            print(latitude, longitude)
            annotation.coordinate = coordinate
            annotation.title = location.valueForKey("name") as? String
            annotation.subtitle = location.valueForKey("acronym") as? String
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            
            print(location[annotation.subtitle!!])
            print(favorites)
            if (favorites.contains(location[annotation.subtitle!!]!)){
                pinView?.pinTintColor = UIColor.purpleColor()
            }
            //pinView?.draggable = true
            //pinView?.pinColor = .Purple
            
            let rightButton: AnyObject! = UIButton(type: UIButtonType.DetailDisclosure)
            pinView?.rightCalloutAccessoryView = rightButton as? UIView
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            view
            performSegueWithIdentifier("mapSegue", sender: view)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "mapSegue",
            let vc = segue.destinationViewController as? DisplayRatingsViewController
            {
            let pin = (sender as! MKAnnotationView)
            let subtitle = pin.annotation!.subtitle!
            print(subtitle)
            vc.location = retrieveLocs()[location[subtitle!]!]
            if favorites.contains(location[subtitle!]!+1){
                vc.isFavorite = true
            }
        }
        else{
            print("not preparing")
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
                
                
        }
    }
    func updateFav() {
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
