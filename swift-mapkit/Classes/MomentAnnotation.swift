//
//  CustomAnnotation.swift
//  swift-mapkit
//
//  Created by Dane Arpino on 3/12/15.
//  Copyright (c) 2015 DA. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MomentAnnotation: NSObject, MKAnnotation {
    let coordinate      : CLLocationCoordinate2D
    var title           : String!
    var subtitle        : String!
    var image           : UIImage!

    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, image:UIImage!){
        self.coordinate = coordinate
        self.title      = title
        self.subtitle   = subtitle
        self.image      = image
        super.init()
    }
    
}
