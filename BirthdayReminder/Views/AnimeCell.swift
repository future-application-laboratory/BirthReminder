//
//  AnimeCell.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 16/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import SnapKit
import SkeletonView

class AnimeCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var background: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        nameLabel.textColor = UIColor.label
        picView.layer.cornerRadius = 10
        picView.layer.masksToBounds = true
        background.backgroundColor = UIColor.cell
        background.layer.cornerRadius = 10
        background.layer.masksToBounds = true
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .clear
        let selectedFrontView = UIView()
        selectedBackgroundView?.addSubview(selectedFrontView)
        selectedFrontView.snp.makeConstraints() { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        }
        selectedFrontView.backgroundColor = UIColor(hexString: "D9D9D9")
        selectedFrontView.layer.cornerRadius = 10
        selectedFrontView.layer.masksToBounds = true

    }
    
}
