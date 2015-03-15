//
//  ViewController.swift
//  swift-mapkit
//
//  Created by Dane Arpino on 3/11/15.
//  Copyright (c) 2015 DA. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Parse

class HomeVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    var droppedLocation:CLLocationCoordinate2D!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapViewGestureRecognizer: UILongPressGestureRecognizer!
    
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        app = AppManager(homeVC: self)
        
        // find user's current location
        var locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        self.mapView.showsBuildings = true
        self.mapView.showsPointsOfInterest = false
      
        // initialize user
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var UUID = userDefaults.objectForKey("ApplicationUniqueIdentifier") as String
        app.doUserInitializations(UUID)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Recognizes long press gesture on mapView
    @IBAction func handleLongPress(sender: AnyObject) {
    
        if (sender.state == UIGestureRecognizerState.Began){
        
            //1 get point that was tapped
            let tapPoint: CGPoint = mapViewGestureRecognizer.locationInView(mapView)
            let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
            
            //2 convert to location
            droppedLocation = CLLocationCoordinate2D(latitude: touchMapCoordinate.latitude,
                longitude: touchMapCoordinate.longitude)

            //3 create and add annotation to map
            let annotation = MomentAnnotation(
                coordinate  : droppedLocation,
                title       : "My Title",
                subtitle    : "My Sub Title",
                image       : nil
            )

            mapView.addAnnotation(annotation)
            var region = app.returnCenterOfMapRegion(droppedLocation) as MKCoordinateRegion
            mapView.setRegion(region, animated:true)
            
            // show modal
            app.delay(0.4,
                closure: {
                    self.performSegueWithIdentifier("segHomeToModal", sender: nil)
                }
            )
            
            // remove annotation in anticipation for a cancel button click
            app.delay(1.0,
                closure: {
                    self.mapView.removeAnnotation(annotation)
                }
            )
            
        }

    }
    
    /*
        Segue-Related
    */
    
    // Triggered by segHomeToModal, responsible for sending data to ModalVC (latitude and longitude)
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let navigationController    = segue.destinationViewController as UINavigationController
        let modalView               = navigationController.viewControllers[0] as ModalVC
        modalView.latitude          = droppedLocation.latitude
        modalView.longitude         = droppedLocation.longitude
        
    }
    
    // Triggered by segModalToHome, sends necessary data back to HomeVC for annotation use
    @IBAction func unwindFromModalVC(segue: UIStoryboardSegue){
        
        var modalVC:ModalVC = segue.sourceViewController as ModalVC
        
        if(modalVC.savedSuccess){
            
            var latitude = modalVC.latitude
            var longitude = modalVC.longitude
            var title = modalVC.txtTitle.text
            var description = modalVC.txtDescription.text
            
            var pinLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation = MomentAnnotation(
                coordinate: droppedLocation,
                title: title,
                subtitle: description,
                image : modalVC.imageView.image
            )
            
            app.delay(0.5,
                closure: {
                    self.mapView.addAnnotation(annotation)
                    self.mapView.selectAnnotation(annotation, animated: true)
                    var region = app.returnCenterOfMapRegion(pinLocation) as MKCoordinateRegion
                    self.mapView.setRegion(region, animated: true)
                }
            )
        }
    }
    
    
    
    /*
        MapView Delegate Methods
    */
    
    // Renders custom annotation pins and callouts
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation is MKUserLocation) {
            //      we don't need to process current location blue dot here
            return nil
        }

    
        // try to dequeue an existing view
        let reuseId = "moment"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if (anView == nil) {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            anView.annotation = annotation
        }
        
        let momentAnnotation = annotation as MomentAnnotation
        
        anView.canShowCallout = true
        
        if (momentAnnotation.image != nil) {
            
            // create two image views, one for the pin, the other for the leftcallout accessory view
            let imageView   = UIImageView(frame: CGRectMake(0, 0, 80, 80))
            imageView.image = momentAnnotation.image;
            imageView.layer.masksToBounds = true
            anView.leftCalloutAccessoryView = imageView
            //anView.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIButton
            
            // x,y values set to ensure image is properly aligned for tap recongition
            var smallImageView = UIImageView(frame: CGRectMake(-15, -15, 30, 30))
            
            smallImageView.image = momentAnnotation.image
            smallImageView.layer.masksToBounds = true
            smallImageView.layer.cornerRadius = smallImageView.layer.frame.size.width / 2
            
            anView.addSubview(smallImageView)
        }
        
        return anView
        
    }

    
    /*
        LocationManager Delegates
    */
    
    // Called once the location has been updated
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var latitude = manager.location.coordinate.latitude
        var longitude = manager.location.coordinate.longitude
        
        //essentially our zoom
        var dLatitude:CLLocationDegrees = 0.01
        var dLongitude:CLLocationDegrees = 0.01
        // --
        
        var span:MKCoordinateSpan = MKCoordinateSpanMake(dLatitude, dLongitude)
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        self.mapView.showsUserLocation = true
        self.mapView.setRegion(region, animated : true)
        
        manager.stopUpdatingLocation()
        
    }
    
    // Called if location failed to be found
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        if (error != nil){
            app.handleError(ErrorArea.HomeVC, spot: ErrorSpot.LocationManager, message: error.localizedDescription)
        }
        
    }
    
}

