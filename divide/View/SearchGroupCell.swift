//
//  SearchGroupCell.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-04.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit

class SearchGroupCell: UITableViewCell {

    @IBOutlet weak var groupNameLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell (groupName: String) {
        self.groupNameLbl.text = groupName
        //self.layer.cornerRadius = self.bounds.height / 2
    }

}
