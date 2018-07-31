//
//  TransactionCell.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-04.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit

enum TransactionType {
    case pending
    case settled
    
}

class TransactionCell: UITableViewCell {

    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var owingLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var owingView: RoundedView!
    
    
    @IBOutlet weak var settledAmountLbl: UILabel!
    
    @IBOutlet weak var settledOwinglbl: UILabel!
    
    @IBOutlet weak var settledDateLbl: UILabel!
    
    @IBOutlet weak var settledDescriptionLbl: UILabel!
    
    
    @IBOutlet weak var settledGroupLbl: UILabel!
    
    @IBOutlet weak var settledOwingView: RoundedView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configureCell(description: String, owing: Bool, date: String, amount: Float, groupName: String, type: TransactionType) {
        if type == .pending {
            self.descriptionLabel.text = description
            self.dateLbl.text = date
            self.amountLbl.text = String(format: "$%.2f", amount)
            self.groupNameLbl.text = groupName
            if owing {
                self.owingLbl.text = "YOU OWE"
                self.owingView.backgroundColor = #colorLiteral(red: 0.8078431373, green: 0.1137254902, blue: 0.007843137255, alpha: 1)
            } else {
                self.owingLbl.text = "YOU ARE OWED"
                self.owingView.backgroundColor = #colorLiteral(red: 0.2784313725, green: 0.6941176471, blue: 0.3137254902, alpha: 1)
            }
        } else if type == .settled{
            self.settledDescriptionLbl.text  = description
            self.settledDateLbl.text = date
            self.settledAmountLbl.text = String(format: "$%.2f", amount)
            self.settledGroupLbl.text = groupName
            if owing {
                self.settledOwinglbl.text = "YOU OWE"
            } else {
                self.settledOwinglbl.text = "YOU ARE OWED"
            }
            self.settledOwingView.backgroundColor = #colorLiteral(red: 0.2784313725, green: 0.6941176471, blue: 0.3137254902, alpha: 1)
        }
    }
}
