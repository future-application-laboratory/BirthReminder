//
//  NotificationViewController.swift
//  iOSNotificationContentExtension
//
//  Created by Captain雪ノ下八幡 on 2018/5/27.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        if let userInfo = notification.request.content.userInfo as? [String:Any],
            let name = userInfo["name"] as? String,
            let birth = userInfo["birth"] as? String,
            let picData = userInfo["picData"] as? Data? {
            nameLabel.text = name
            birthdayLabel.text = birth.toLocalizedDate(with: "MMM/d")
            if let picData = picData {
                imageView.image = UIImage(data: picData)
            }
        }
    }
    
}
