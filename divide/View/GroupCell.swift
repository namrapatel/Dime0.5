//
//  GroupCell.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-04.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupType: UIImageView!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var memberNumLbl: UILabel!
    
    func configureCell(groupName: String, memberCount: Int) {
        self.groupNameLbl.text = groupName
        self.memberNumLbl.text = "\(memberCount) members"
    }
}
