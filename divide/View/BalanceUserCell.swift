//
//  BalanceUserCell.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-05.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
import Firebase
class BalanceUserCell: UITableViewCell {

    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var paidLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell (email: String, paid: Bool, amount: Float, transaction: Transaction) {
        if transaction.settled.contains(email) {
            self.paidLbl.text = "PAID"
        } else {
            if Auth.auth().currentUser?.email == email {
                self.paidLbl.text = "OWE"
            } else {
                self.paidLbl.text = "OWES"
            }
        }
        if Auth.auth().currentUser?.email == email {
            userEmailLbl.text = "You"
        } else {
            DataService.instance.getName(forEmail: email, handler: { (name) in
                self.userEmailLbl.text = name
            })
        }
        
        amountLbl.text = String(format: "$%.2f", amount)
    }

}
