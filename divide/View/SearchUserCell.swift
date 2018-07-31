//
//  SearchUserCell.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-04.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {


    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var friendEmailLbl: UILabel!
    @IBOutlet weak var payeeEmailLbl: UILabel!
    @IBOutlet weak var friendEmailLblFromGroup: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell (email: String, sender: String) {
        if sender == "transaction"{
            self.userEmailLbl.text = email
        } else if sender == "group"{
            self.friendEmailLbl.text = email
        } else if sender == "addMember" {
            self.friendEmailLblFromGroup.text = email
        } else if sender == "payee" {
            self.payeeEmailLbl.text = email
        }
    }

}
