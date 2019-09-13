//
//  AppDelegate.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 19/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//
//  swiftlint:disable line_length

import UIKit
import WatchConnectivity
import NotificationCenter
import Moya
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate,
ManagedObjectContextUsing {

    var window: UIWindow?

    // FIXME: Help wanted: CoreData Spotlight Integration not working
    static let context = createDataMainContext { storeDescription, model in
        let coreDataCoreSpotlightDelegate = NSCoreDataCoreSpotlightDelegate(forStoreWith: storeDescription, model: model)
        storeDescription.setOption(coreDataCoreSpotlightDelegate, forKey: NSCoreDataCoreSpotlightExporter)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Notifications
        UNUserNotificationCenter.current().delegate = self

        // Watch Connectivity Configuration
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }

        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "notificationLoaded") {
            NotificationManager.reloadNotifications()
            defaults.set(true, forKey: "notificationLoaded")
        }

        UIApplication.shared.registerForRemoteNotifications()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? context.save()
    }

    // WatchConnectivity Sessions
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }

    func syncWithAppleWatch() {
        let session = WCSession.default
        guard WCSession.isSupported(),
            session.isWatchAppInstalled
            else { return }
        session.outstandingFileTransfers.forEach { $0.cancel() }
        let request = PeopleToSave.sortedFetchRequest
        do {
            let people = try context.fetch(request).filterOutNil { person -> PeopleToTransfer? in
                guard person.shouldSync else { return nil }
                let picData = person.picData
                return PeopleToTransfer(name: person.name, birth: person.birth, picData: picData)
            }
            let data = try JSONEncoder().encode(people)
            let fileUrl = URL.temporary
            try? data.write(to: fileUrl)
            session.transferFile(fileUrl, metadata: ["type": "BR/reload"])
        } catch {
            NSLog("Failed to sync with AW")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        syncWithAppleWatch()
    }

    // Remote notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        let defaults = UserDefaults.standard
        if let alreadyToken = defaults.string(forKey: "remoteToken") {
            if alreadyToken == token { return }
        }
        sendToken(token)
    }

    private func sendToken(_ token: String) {
        NetworkController.networkQueue.async {
            NetworkController.provider.request(.notification(withToken: token)) { response in
                switch response {
                case .success(let result):
                    if result.statusCode != 200 {
                        self.sendToken(token)
                    } else {
                        let defaults = UserDefaults()
                        defaults.set(token, forKey: "remoteToken")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.sendToken(token)
                }
            }
        }
    }

}

extension ManagedObjectContextUsing {
    var context: NSManagedObjectContext! {
        return AppDelegate.context
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let request = response.notification.request
        if request.content.categoryIdentifier == "UpcomingBirthday" {
            if let uuid = UUID(uuidString: request.identifier) {
                DispatchQueue.main.async {
                    if let person = PeopleToSave.specified(withID: uuid, in: self.context) {
                        BirthCardController.show(for: person)
                    }
                }
            }
        }
        completionHandler()
    }

}
