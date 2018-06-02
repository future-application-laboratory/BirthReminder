//
//  AnimeCell.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 16/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import SnapKit

class AnimeCell: RoundCornerTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var picView: UIImageView!

    weak var picPack: PicPack? {
        didSet {
            picView.image = picPack?.pic
        }
    }
    weak var delegate: CopyrightViewing?

    override func awakeFromNib() {
        super.awakeFromNib()
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(showCopyright(_:)))
        addGestureRecognizer(recognizer)
        backgroundColor = .clear
        nameLabel.textColor = .label
        picView.layer.cornerRadius = 10
        picView.layer.masksToBounds = true

        nameLabel.text = ""
        picPack = nil
    }

    @objc func showCopyright(_ sender: UIGestureRecognizer) {
        let location = sender.location(in: self)
        if let copyright = picPack?.copyright,
            picView.frame.contains(location),
            sender.state == .began {
            delegate?.showCopyrightInfo(copyright)
        }
    }

}
