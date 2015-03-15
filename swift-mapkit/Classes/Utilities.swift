//
//  Utilities.swift
//  swift-mapkit
//
//  Created by Dane Arpino on 3/14/15.
//  Copyright (c) 2015 DA. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MapKit

extension AppManager {
    
    // A "setTimeout"-like function for Swift
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // Centers map on particular coordinate
    func returnCenterOfMapRegion(location: CLLocationCoordinate2D) -> MKCoordinateRegion{
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        
        return region
    }
    
    // Cleanse string, currrently just remove whitespace
    func cleanse (val:String) -> String{
        return val.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
}
