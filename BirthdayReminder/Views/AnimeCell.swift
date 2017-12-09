//
//  AnimeCell.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 16/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import SnapKit

class AnimeCell: RoundConerTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var picView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        nameLabel.textColor = UIColor.label
        picView.layer.cornerRadius = 10
        picView.layer.masksToBounds = true
    }
    
}
