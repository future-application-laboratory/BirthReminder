//
//  RoundCornerTableViewCell.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 19/11/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import SnapKit

class RoundCornerTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        
        backgroundView = UIView()
        let insideBackgroundView = UIView()
        backgroundView?.addSubview(insideBackgroundView)
        insideBackgroundView.snp.makeConstraints() { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        }
        insideBackgroundView.backgroundColor = .cell
        insideBackgroundView.layer.cornerRadius = 10
        insideBackgroundView.layer.masksToBounds = true
    }

}
