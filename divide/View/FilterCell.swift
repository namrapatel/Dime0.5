//
//  FilterCell.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-27.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {

    @IBOutlet weak var filterLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell (type: String) {
        filterLbl.text = type
    }

}
