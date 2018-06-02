//
//  NotificationManager.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 09/12/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import CoreData
import MobileCoreServices

enum NotificationManager {

    static public func reloadNotifications() {
        let notifyQueue = DispatchQueue(label: "notification", qos: .userInitiated)
        notifyQueue.async {
            let notificationCenter = UNUserNotificationCenter.current()
            // remove all the notifications before
            notificationCenter.removeAllPendingNotificationRequests()
            // add notifications
            DispatchQueue.main.async {
                let fetchRequest = PeopleToSave.sortedFetchRequest
                let people = try? AppDelegate.context.fetch(fetchRequest)
                notifyQueue.async {
                    people?.forEach { person in
                        onInsert(person: person)
                    }
                }
            }
        }
    }

    static func onInsert(person: PeopleToSave) {
        let notificationCenter = UNUserNotificationCenter.current()
        let birth = person.birth.toDate()!
        var components = DateComponents()
        components.month = birth.month
        components.day = birth.day
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = String.localizedStringWithFormat(
            NSLocalizedString("It's %@'s birthday", comment: "It's %@'s birthday"),
            person.name)
        content.body = String.localizedStringWithFormat(
            NSLocalizedString("%@ is %@'s birthday, let's celebrate!", comment: "%@ is %@'s birthday, let's celebrate!"),
            person.birth.toLocalizedDate()!, person.name)
        content.sound = .default()
        content.categoryIdentifier = "UpcomingBirthday"
        if let pngData = person.picData,
            let image = UIImage(data: pngData),
            let jpegData = UIImageJPEGRepresentation(image, 1.0) {
            let picUrl = URL.temporary
            if let _ = try? jpegData.write(to: picUrl),
                let attachment = try? UNNotificationAttachment(identifier: person.uuid.uuidString, url: picUrl, options: [UNNotificationAttachmentOptionsTypeHintKey: kUTTypeJPEG]) {
                content.attachments.append(attachment)
            }
        }
        content.userInfo["name"] = person.name
        content.userInfo["birth"] = person.birth
        content.userInfo["picData"] = person.picData
        let notificationRequest = UNNotificationRequest(identifier: person.uuid.uuidString, content: content, trigger: trigger)
        notificationCenter.add(notificationRequest, withCompletionHandler: nil)
    }

    static func onRemove(person: PeopleToSave) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [person.uuid.uuidString])
    }

    static func onModify(person: PeopleToSave) {
        onRemove(person: person)
        onInsert(person: person)
    }

}
