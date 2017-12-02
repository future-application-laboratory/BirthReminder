//
//  PersonalCell.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 16/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

class PersonalCell: RoundConerTableViewCell {

    @IBOutlet weak var picView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var birthLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        nameLabel.textColor = UIColor.label
        birthLabel.textColor = UIColor.label
        picView.layer.cornerRadius = 10
        picView.layer.masksToBounds = true
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }

}
