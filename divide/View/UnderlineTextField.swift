//
//  UnderlineTextField.swift
//  Funder
//
//  Created by Namra Patel on 2018-06-18.
//  Copyright © 2018 Namra Patel. All rights reserved.
//

import UIKit
import ReactiveKit
@IBDesignable
class UnderlineTextField: UITextField {
    private var padding = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
    override func awakeFromNib() {
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func setupView() {
        var frameRect: CGRect = self.frame
        frameRect.size.height = 30
        self.frame = frameRect
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UI.Colours.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }

    
}
