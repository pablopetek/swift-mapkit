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

class PhotoLibraryModalViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet var btnCancel: UIBarButtonItem!
    @IBOutlet var txtDescription: UITextView!
    @IBOutlet var lblLatitude: UILabel!
    @IBOutlet var lblLongitude: UILabel!
    @IBOutlet var btnDone: UIBarButtonItem!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var btnLibrary: UIButton!
    @IBOutlet var txtTitle: UITextField!
    
    let textViewPlaceholder:String = "And dont't skimp on the details!"
    var latitude:CLLocationDegrees!
    var longitude:CLLocationDegrees!
    var placeholderLabel :UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnDone.enabled = false
        self.txtDescription.delegate = self
        
        
        //add border to textview
        var borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        txtDescription.layer.borderWidth = 0.5
        txtDescription.layer.borderColor = borderColor.CGColor
        txtDescription.layer.cornerRadius = 5.0
        
        //add label to textview, serves as placeholder text
        placeholderLabel = UILabel()
        placeholderLabel.text = textViewPlaceholder
        placeholderLabel.font = UIFont.systemFontOfSize(txtDescription.font.pointSize)
        placeholderLabel.sizeToFit()
        txtDescription.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, txtDescription.font.pointSize / 2)
        placeholderLabel.textColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        placeholderLabel.hidden = countElements(txtDescription.text) != 0
        
        self.lblLatitude.text = String(format: "%f", latitude)
        self.lblLongitude.text = String(format: "%f", longitude)
        
    }
    
    @IBAction func btnCancel_pressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func btnLibrary_pressed(sender: UIButton) {
        var photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .PhotoLibrary
        self.presentViewController(photoPicker, animated: true, completion: {})
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: {})
        checkUpdateDone()
    }
    
    func checkUpdateDone(){

        self.btnDone.enabled = (countElements(txtDescription.text) > 0) && (countElements(txtTitle.text) > 0) && (imageView.image != nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        println(countElements(textField.text))
        checkUpdateDone();
        return true
    }
    
    // Create placeholder-like interaction for text view by showing/hiding a label
    func textViewDidChange(textView: UITextView) {
        checkUpdateDone()
        placeholderLabel.hidden = countElements(textView.text) != 0
    }
    
    func closeKeyboard(){
        self.view.endEditing(true)
    }
    
    //IOS Touch Functions
    // closes text input when user touches screen
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        closeKeyboard()
    }
    
    //UITextField Delegate
    // closes the text input when return button is clicked
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()// keyboard should go away
        return true
    }
}