//
//  AddUserCell.swift
//  Funder
//
//  Created by Namra Patel on 2017-11-29.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit

class AddUserCell: UITableViewCell {

    //Group
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    //Group Details
    @IBOutlet weak var chosenPayeeCell: UILabel!
    @IBOutlet weak var chosenPayeeName: UILabel!
    
    //Add member
    @IBOutlet weak var chosenUserEmailLbl: UILabel!
    @IBOutlet weak var chosenUserNameLbl: UILabel!
    
    //Remove member
    @IBOutlet weak var removeMemberCell: UILabel!
    @IBOutlet weak var removeMemberName: UILabel!
    
    @IBOutlet weak var deleteBtn: RoundedOutlineButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configureCell(email: String, name: String, sender: String) {
        if sender == "group" {
            self.emailLbl.text = email
            self.nameLbl.text = name
            self.deleteBtn.isHidden = false
        } else if sender == "addMember" {
            self.chosenUserEmailLbl.text = email
            self.chosenUserNameLbl.text = name
        } else if sender == "groupDetails" {
            self.chosenPayeeCell.text = email
            self.chosenPayeeName.text = name
        } else if sender == "removeMember" {
            self.removeMemberCell.text = email
            self.removeMemberName.text = name
        }
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    func returnEmail() -> String {
        return self.emailLbl.text!
    }
            
}
