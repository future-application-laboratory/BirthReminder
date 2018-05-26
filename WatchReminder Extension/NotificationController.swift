//
//  NotificationController.swift
//  WatchReminder Extension
//
//  Created by Jacky Yu on 25/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications


class NotificationController: WKUserNotificationInterfaceController {

    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var birthdayLabel: WKInterfaceLabel!
    @IBOutlet weak var interfaceImage: WKInterfaceImage!
    
    override init() {
        // Initialize variables here.
        super.init()
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
        if let userInfo = notification.request.content.userInfo as? [String:Any],
            let name = userInfo["name"] as? String,
            let birth = userInfo["birth"] as? String,
            let picData = userInfo["picData"] as? Data? {
            nameLabel.setText(name)
            birthdayLabel.setText(birth.toLocalizedDate(with: "MMM-d"))
            interfaceImage.setImageData(picData)
            completionHandler(.custom)
        } else {
            completionHandler(.default)
        }
    }
    
}
