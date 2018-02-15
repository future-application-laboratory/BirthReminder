//
//  ContactViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import SafariServices

class ContactViewController: ViewController {
    let urls: [URL] = [
        "mailto://CaptainYukinoshitaHachiman@tcwq.tech",
        "https://space.bilibili.com/5766898",
        "https://github.com/CaptainYukinoshitaHachiman"
    ]
    
    @IBAction func didTouch(_ sender: UIButton) {
        let tag = sender.tag
        if urls.indices.contains(sender.tag) {
            let url = urls[tag]
            if sender.tag == 0 {
                UIApplication.shared.open(url)
            } else {
                let sfController = SFSafariViewController(url: url)
                present(sfController, animated: true)
            }
        }
    }
}
