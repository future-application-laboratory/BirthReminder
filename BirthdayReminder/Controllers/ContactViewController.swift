//
//  ContactViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    @IBAction func didTouch(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            let url = URL(string: "mailto://CaptainYukinoshitaHachiman@ProtonMail.com")!
            UIApplication.shared.open(url)
        case 1:
            let url = URL(string: "https://space.bilibili.com/5766898")!
            UIApplication.shared.open(url)
        case 2:
            let url = URL(string: "https://github.com/CaptainYukinoshitaHachiman")!
            UIApplication.shared.open(url)
        default:
            break
        }
    }
    
}
