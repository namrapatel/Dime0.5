//
//  GroupIconCell.swift
//  Funder
//
//  Created by Namra Patel on 2018-01-24.
//  Copyright © 2018 Namra Patel. All rights reserved.
//

import UIKit

class GroupIconCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    
    func configureCell (image: UIImage) {
        icon.image = image
    }
}
