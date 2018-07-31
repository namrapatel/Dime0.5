//
//  RoundedModalView.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-09.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
@IBDesignable
class RoundedModalView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 7.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    override func awakeFromNib() {
        self.setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }
    
    func setupView () {
        self.layer.cornerRadius = cornerRadius
    }
}
