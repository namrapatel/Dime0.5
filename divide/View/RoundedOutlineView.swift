//
//  RoundedOutlineView.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-14.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
@IBDesignable
class RoundedOutlineView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 7.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
            self.layer.borderWidth = 1.0
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
        self.layer.borderColor = #colorLiteral(red: 0.0431372549, green: 0.1960784314, blue: 0.3490196078, alpha: 1)
        self.layer.borderWidth = 1.0
    }
}
