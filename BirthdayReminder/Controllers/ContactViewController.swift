//
//  ContactViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

class ContactViewController: ViewController {
    let urls: [URL] = [
        "mailto://CaptainYukinoshitaHachiman@tcwq.tech",
        "https://space.bilibili.com/5766898",
        "https://github.com/CaptainYukinoshitaHachiman"
    ]

    @IBAction func didTouch(_ sender: UIButton) {
        if urls.indices.contains(sender.tag) {
            UIApplication.shared.open(urls[sender.tag])
        }
    }
}
