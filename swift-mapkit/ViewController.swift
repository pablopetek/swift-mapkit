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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locManager = CLLocationManager()
    var droppedLocation:CLLocationCoordinate2D!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapViewGestureRecognizer: UILongPressGestureRecognizer!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Update location once the application has loaded
        self.locManager.delegate = self
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locManager.requestWhenInUseAuthorization()
        self.locManager.startUpdatingLocation()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destViewController:PhotoLibraryModalViewController = segue.destinationViewController as PhotoLibraryModalViewController
        destViewController.latitude = droppedLocation.latitude
        destViewController.longitude = droppedLocation.longitude
    }
    
    //    Gesture recognition --
    @IBAction func handleLongPress(sender: AnyObject) {
    
        if (sender.state == UIGestureRecognizerState.Began){
        
            //let's drop a pin ... annotation ... w/e
            
            //1 get point that was tapped
            let tapPoint: CGPoint = mapViewGestureRecognizer.locationInView(mapView)
            let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
            
            //2 convert to location
            droppedLocation = CLLocationCoordinate2D(latitude: touchMapCoordinate.latitude,
                longitude: touchMapCoordinate.longitude)

            //3 create and add annotation to map
            let annotation = CustomAnnotation(
                coordinate: droppedLocation,
                title: "My Title",
                subtitle: "My Sub Title"
            )

            mapView.addAnnotation(annotation)
            setCenterOfMapToLocation(droppedLocation)
            
            //show modal
            delay(0.4,
                closure: {
                    self.performSegueWithIdentifier("PhotoLibarayModalSegue", sender: nil)
                }
            )
            
            delay(2.0,
                closure: {
                    //remove annotation in anticipation for a cancel button click
                    //if the user geo-tags an image, we can recreate the "real" annotation
                    self.mapView.removeAnnotation(annotation)
                })
            
        }

        
    }
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    /* Delegate Methods for LocationManager */
    
    //Called once the location has been updated
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
        
        stopUpdatingLocation()
        
    }
    
    func stopUpdatingLocation (){
        self.locManager.stopUpdatingLocation()
    }
    
    //Called if location failed to be found
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if (error != nil){
            println("Error! " + error.localizedDescription)
        }
    }
    
}

