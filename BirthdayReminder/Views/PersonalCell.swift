//
//  PersonalCell.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 16/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

class PersonalCell: UITableViewCell {

    @IBOutlet weak var picView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var birthLabel: UILabel!
    
    private var data: PeopleToSave!
    
    public func setData(_ data: PeopleToSave) {
        if let imgData = data.picData {
            picView.image = UIImage(data: imgData)
        } else {
            // loading anime
        }
        nameLabel.text = data.name
        birthLabel.text = data.birth.toLocalizedDate(withStyle: .long)
    }
    
    private var status = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.background
        nameLabel.textColor = UIColor.label
        birthLabel.textColor = UIColor.label
        picView.layer.cornerRadius = 10
        picView.layer.masksToBounds = true
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    public func changeBirthLabel() {
        status = !status
        let birth = data.birth
        birthLabel.text = status ? birth.toLocalizedDate(withStyle: .long) : birth.toLeftDays()
    }
    
}
