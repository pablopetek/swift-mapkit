//
//  AppManager.swift
//  swift-mapkit
//
//  Created by Dane Arpino on 3/14/15.
//  Copyright (c) 2015 DA. All rights reserved.
//
//
//  Grants global access to useful variables and utility functions

import UIKit
import Parse
import MapKit

var app: AppManager!

enum ErrorArea : String, Printable {
    case Parse              = "Parse"
    case HomeVC             = "HomeVC"
    case ModalVC            = "ModalVC"
    case Util               = "Util"
    
    var description : String {
        get {
            return self.rawValue
        }
    }
}

enum ErrorSpot : String, Printable {
    case GetUser            = "GetUser"
    case CreateUser         = "CreateUser"
    case UpdateUser         = "UpdateUser"
    case LocationManager    = "LocationManager"
    case ReverseGeoCode     = "ReverseGeoCode"
    case CreateMoment       = "CreateMoment"
    case GetMoments         = "GetMoments"
    case GetImageData       = "GetImageData"
    
    var description : String {
        get {
            return self.rawValue
        }
    }
}

struct AppUser {
    var objectID            : String!
    var UUID                : String!
    var createdAt           : NSDate!
    var updatedAt           : NSDate!
    var lastActiveAt        : NSDate!
    var moments             : [Moment]!
    var pAppUser            : PFObject!
}

struct Moment {
    var objectId            : String!
    var createdAt           : NSDate!
    var updatedAt           : NSDate!
    var location            : PFGeoPoint!
    var UUID                : String!
    var image               : UIImage!
    var title               : String!
    var description         : String!
    var pMoment             : PFObject!
}

class AppManager {
    
    var user:AppUser!
    var homeVC:HomeVC!
    
    init(homeVC:HomeVC!){
        self.homeVC = homeVC
    }
    
    // Checks if a user record exists in Parse database, updates data if exists, creates record if not
    func doUserInitializations(UUID:String) {

        var userQuery = PFQuery(className: "AppUser")
        
        userQuery.whereKey("UUID", equalTo: UUID)
        
        userQuery.findObjectsInBackgroundWithBlock({
            (result:[AnyObject]!, error:NSError!) -> Void in
            
            if(error != nil) {
                self.handleError(ErrorArea.Parse, spot: ErrorSpot.GetUser, message: error.localizedDescription)
            }
            
            if (result.count == 0) {
                
                // user does not exist, let's create a user record, then initialize local user variable
                self.pCreateUser(UUID)
                
            } else {
                
                // user exists, update lastActiveAt, then initialize local user variable
                self.pUpdateUserActive(UUID, userRaw: result[0])
                
            }
            
        })
        
    }
    
    // Gets all user moments from ParseDB
    func pGetUserMoments() {
        var momentQuery = PFQuery(className: "Moment")
        
        momentQuery.whereKey("parent", equalTo: user.pAppUser)
        
        momentQuery.findObjectsInBackgroundWithBlock({
            (result:[AnyObject]!, error:NSError!) -> Void in
            
            if(error != nil) {
                self.handleError(ErrorArea.Parse, spot: ErrorSpot.GetMoments, message: error.localizedDescription)
            }
            
            // Successfully retreived moments
            
            // add to local collection 
            for moment in result {
                
                var m           = moment as PFObject
                var geoPoint    = m["location"] as PFGeoPoint
                var title       = m["title"] as String
                var description = m["description"] as String
                var pImage      = m["image"] as PFFile

                // acutally load the image data from Parse
                pImage.getDataInBackgroundWithBlock({
                    (imageData:NSData!, error:NSError!) -> Void in
                    
                    if(error != nil){
                        self.handleError(ErrorArea.Parse, spot: ErrorSpot.GetImageData, message: error.localizedDescription)
                    }
                    var image   = UIImage(data: imageData)
                    
                    self.user.moments.append(
                    Moment(
                            objectId    : m.objectId,
                            createdAt   : m.createdAt,
                            updatedAt   : m.updatedAt,
                            location    : geoPoint,
                            UUID        : self.user.UUID,
                            image       : image,
                            title       : title,
                            description : description,
                            pMoment     : m
                        )
                    )
                    
                    // render annotations on map
                    var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                    
                    let annotation = MomentAnnotation(
                        coordinate      : location,
                        title           : title,
                        subtitle        : description,
                        image           : image
                    )
                    
                    self.homeVC.mapView.addAnnotation(annotation)
                })
            }
            
        })

    }
    
    // Creates an AppUser record in the Parse database, then initializes local user variable
    func pCreateUser(UUID:String) {
        
        var user                = PFObject(className: "AppUser")
        var currentDate         = NSDate()
        
        user["lastActiveAt"]    = currentDate
        user["UUID"]            = UUID
        
        user.saveInBackgroundWithBlock({
            (success:Bool!, error:NSError!) -> Void in
            
            if (error != nil) {
                self.handleError(ErrorArea.Parse, spot: ErrorSpot.CreateUser, message: error.localizedDescription)
            }
            
            // user created successfully, now initalize local user variable
            self.initializeUserLocal(user.objectId, UUID: UUID, createdAt: user.createdAt, updatedAt: user.updatedAt, lastActiveAt: currentDate, pAppUser: user)
            
        })
        
    }
    
    // Creates a record within the Moment table in Parse DB, adds to user's local collection
    func pCreateMoment(latitude:CLLocationDegrees, longitude:CLLocationDegrees, title:String, description:String, image:UIImage, sender:ModalVC) {
        
        var moment              = PFObject(className: "Moment")
        var geoPoint            = PFGeoPoint(latitude: latitude, longitude: longitude)
        var title               = app.cleanse(title)
        var description         = app.cleanse(description)
        var image               = image
        var imageData:NSData    = UIImageJPEGRepresentation(image, 1.0)
        var imageFile           = PFFile(data: imageData)
        
        moment["parent"]        = user.pAppUser
        moment["location"]      = geoPoint
        moment["title"]         = title
        moment["description"]   = description
        moment["image"]         = imageFile
        
        moment.saveInBackgroundWithBlock({
            (success:Bool!, error:NSError!) -> Void in
            
            if(error != nil) {
                self.handleError(ErrorArea.Parse, spot: ErrorSpot.CreateMoment, message: error.localizedDescription)
            } else {

                // successfullly saved moment
                
                // --- hide modal
                sender.savedSuccess = true
                sender.performSegueWithIdentifier("segModalToHome", sender: self)
                
                // --- add to user's local collection
                self.user.moments.append(
                    Moment(
                        objectId    : moment.objectId,
                        createdAt   : moment.createdAt,
                        updatedAt   : moment.updatedAt,
                        location    : geoPoint,
                        UUID        : self.user.UUID,
                        image       : image,
                        title       : title,
                        description : description,
                        pMoment     : moment
                    )
                )
            }
        })
    }
    
    // For existing users, update lastActiveAt field in Parse database, Gets Moments
    func pUpdateUserActive (UUID:String, userRaw:AnyObject) {
        
        var user                = userRaw as PFObject
        var currentDate         = NSDate()
        
        user["lastActiveAt"]    = currentDate
        
        user.saveInBackgroundWithBlock({
            (succes: Bool!, error:NSError!) -> Void in
            
            if (error != nil){
                self.handleError(ErrorArea.Parse, spot: ErrorSpot.UpdateUser, message: error.localizedDescription)
            }
            
            // user updated, intialize local user variable
            self.initializeUserLocal(user.objectId, UUID: UUID, createdAt: user.createdAt, updatedAt: user.updatedAt, lastActiveAt: currentDate, pAppUser: user)
            
            // get moments
            self.pGetUserMoments()
        })
    }
    
    // Initializes user variable
    func initializeUserLocal (objectID: String, UUID: String, createdAt: NSDate, updatedAt: NSDate, lastActiveAt: NSDate, pAppUser:PFObject){
        user = AppUser(
            objectID        : objectID,
            UUID            : UUID,
            createdAt       : createdAt,
            updatedAt       : updatedAt,
            lastActiveAt    : lastActiveAt,
            moments         : [Moment](),
            pAppUser        : pAppUser
        )
    }
    
    // Print errors
    func handleError (area: ErrorArea, spot:ErrorSpot, message: String){
        println("Error handled: \(area) - \(spot) - \(message)")
    }
}
