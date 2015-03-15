//
//  PaddedTextField.swift
//  swift-mapkit
//
//  Created by Dane Arpino on 3/14/15.
//  Copyright (c) 2015 DA. All rights reserved.
//

import Foundation
import UIKit


// -- Creating padding-left for elements
extension UITextField {
    @IBInspectable var padding_left: CGFloat {
        get {
            println("WARNING no getter for UITextField.padding_left")
            return 0
        }
        set (f) {
            layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0)
        }
    }
}

extension UITextView {
    @IBInspectable var paddidng_left: CGFloat {
        get {
            println("WARNING no getter for UITextField.padding_left")
            return 0
        }
        set (f) {
            layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0)
        }
    }
}