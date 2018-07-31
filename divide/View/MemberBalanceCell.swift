//
//  MemberBalanceCell.swift
//  Funder
//
//  Created by Namra Patel on 2018-01-28.
//  Copyright © 2018 Namra Patel. All rights reserved.
//

import UIKit

class MemberBalanceCell: UICollectionViewCell {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var owingLabel: UILabel!
    @IBOutlet weak var owingView: RoundedView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    func configureCell (name: String, amount: Float, owing: Bool) {
        if owing {
            self.owingLabel.text = "YOU OWE"
            self.owingView.backgroundColor = #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)
        } else {
            self.owingLabel.text = "OWES YOU"
            self.owingView.backgroundColor = #colorLiteral(red: 0.2784313725, green: 0.6941176471, blue: 0.3137254902, alpha: 1)
        }
        self.amountLabel.text = String(format: "$%.2f", amount)
        self.userNameLabel.text = name
    }
}
