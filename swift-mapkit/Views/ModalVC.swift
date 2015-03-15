//
//  PhotoLibarayModalViewController.swift
//  swift-mapkit
//
//  Created by Dane Arpino on 3/12/15.
//  Copyright (c) 2015 DA. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import Parse

//http://stackoverflow.com/a/24030113 -- allows for unwinding of segue
@objc(ModalVC) class ModalVC: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate   {

    @IBOutlet var btnCancel: UIBarButtonItem!
    @IBOutlet var txtDescription: UITextView!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var btnDone: UIBarButtonItem!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var btnLibrary: UIButton!
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var indActivity: UIActivityIndicatorView!
    @IBOutlet var indActivityBackgroundView: UIView!
    
    let textViewPlaceholder:String = "What happened here?"
    let titleMaxLength = 15
    let descriptionMaxLength = 30
    var latitude:CLLocationDegrees!
    var longitude:CLLocationDegrees!
    var placeholderLabel :UILabel!
    var savedSuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indActivity.hidden=true
        self.indActivityBackgroundView.hidden=true
        self.indActivityBackgroundView.opaque = true
        var bgColor = UIColor.whiteColor()
        self.indActivityBackgroundView.backgroundColor = bgColor.colorWithAlphaComponent(0.7)
        self.btnDone.enabled = false
        self.txtDescription.delegate = self
        
        // prepare textView for placeholder hack
        var borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        txtDescription.layer.borderWidth = 0.5
        txtDescription.layer.borderColor = borderColor.CGColor
        txtDescription.layer.cornerRadius = 5.0
        placeholderLabel = UILabel()
        placeholderLabel.text = textViewPlaceholder
        placeholderLabel.font = UIFont.systemFontOfSize(txtDescription.font.pointSize)
        placeholderLabel.frame.origin = CGPointMake(5, txtDescription.font.pointSize / 2)
        placeholderLabel.textColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        placeholderLabel.hidden = countElements(txtDescription.text) != 0
        placeholderLabel.sizeToFit()
        txtDescription.addSubview(placeholderLabel)
        
        txtTitle.becomeFirstResponder()
        
        
        // reverse geocode and set text property of footer label to the location details
        updateLabeReverseGeoCode(latitude, longitude: longitude)
    }
    
    // Performes reverse geoCode to obtain address details given supplied lat/long variables
    func updateLabeReverseGeoCode(latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        
        var location = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if (error != nil) {
                app.handleError(ErrorArea.Util, spot: ErrorSpot.ReverseGeoCode, message: error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                var city = (pm.locality != nil) ? pm.locality : ""
                var sub = (pm.subLocality != nil) ? pm.subLocality : "" // neighborhood, "Midtown", "Williamsburg", "Bushwick", etc
                var street = (pm.thoroughfare != nil) ? pm.thoroughfare : ""
                var addressNumber  = (pm.subThoroughfare != nil) ? pm.subThoroughfare : ""
                var zipCode = (pm.postalCode != nil) ? pm.postalCode : ""
                
                var address = "\(addressNumber) \(street), \(city)"
                
                self.lblLocation.text = address
            }
            else {
                app.handleError(ErrorArea.Util, spot: ErrorSpot.ReverseGeoCode, message: error.localizedDescription)
            }
        })
    }
    
    // UITextField onKeyPres() event, checks whether btnDone should be enabled
    @IBAction func txtTitle_onChanged(sender: AnyObject) {
        checkUpdateDone()
    }
    
    // UIButton click(), responsible for saving moment to Parse DB
    @IBAction func btnDone_pressed(sender: AnyObject) {
        // Responsible for saving stuff to Parse
        
        // --- show activity indicator
        showActivityIndicator()
        
        // --- save
        var image = imageView.image
        
        app.pCreateMoment(latitude, longitude:longitude, title:txtTitle.text, description:txtDescription.text, image: imageView.image!, sender:self)
        
    }
    
    // Displays semi-transparent view and activity indicator while saving occurs
    func showActivityIndicator(){
        
        // --- show activity indicator
        self.view.bringSubviewToFront(indActivityBackgroundView)
        self.view.bringSubviewToFront(indActivity)
        self.indActivity.hidden = false
        self.indActivityBackgroundView.hidden = false
        self.indActivity.startAnimating()
        
    }
    
    // Fired when user clicks image browsing button
    @IBAction func btnLibrary_pressed(sender: UIButton) {
        var photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .PhotoLibrary
        self.presentViewController(photoPicker, animated: true, completion: {})
    }
    
    // Fired when image is sleected from Photo Library
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        btnLibrary.setTitle("", forState: UIControlState.allZeros)
        self.dismissViewControllerAnimated(true, completion: {})
        checkUpdateDone()
    }
    
    // Determines whether btnDone should be enabled. All 3 inputs must have values - Title, Description, & Image
    func checkUpdateDone(){
        self.btnDone.enabled = (countElements(txtDescription.text) > 0) && !txtTitle.text.isEmpty && (imageView.image != nil)
    }
    
    // Create placeholder-like interaction for text view by showing/hiding a label
    func textViewDidChange(textView: UITextView) {
        checkUpdateDone()
        placeholderLabel.hidden = countElements(textView.text) != 0
    }
    
    // Max-length hack for UITextView
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(range.length + range.location > countElements(txtDescription.text))
        {
            return false;
        }
        
        var newLength = countElements(txtDescription.text) - range.length;
        return (newLength > descriptionMaxLength) ? false : true;
    }
    
    // Max-length hack for UITextField
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(range.length + range.location > countElements(txtTitle.text))
        {
            return false;
        }
        
        var newLength = countElements(txtTitle.text) - range.length;
        return (newLength > titleMaxLength) ? false : true;
    }
    
    // Closes the mobile keyborad on non-UI-element touches
    func closeKeyboard(){
        self.view.endEditing(true)
    }
    
    // IOS Touch Functions
    // closes text input when user touches screen
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        closeKeyboard()
    }
    
    // UITextField Delegate
    // closes the text input when return button is clicked
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()// keyboard should go away
        return true
    }
}