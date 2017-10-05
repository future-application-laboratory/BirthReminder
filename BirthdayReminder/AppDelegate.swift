//
//  AppDelegate.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 19/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import WatchConnectivity
import NotificationCenter
import SCLAlertView
import Moya

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    let context = createDataMainContext()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Watch Connectivity Configuration
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        let defaults = UserDefaults()
        if !defaults.bool(forKey: "beenLaunched") {
            window?.rootViewController = tutorialController
        }
        
        UIApplication.shared.statusBarStyle = .lightContent
        
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // WatchConnectivity Sessions
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func syncWithAppleWatch() {
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isWatchAppInstalled {
                session.outstandingFileTransfers.forEach { transfer in
                    transfer.cancel()
                }
                let request = PeopleToSave.sortedFetchRequest
                let people = try! context.fetch(request).flatMap { person -> PeopleToTransfer? in
                    guard person.shouldSync else { return nil }
                    return PeopleToTransfer(withName: person.name, birth: person.birth, picData: person.picData)
                }
                let data = NSKeyedArchiver.archivedData(withRootObject: people)
                let manager = FileManager()
                let docUrl = manager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                let fileUrl = docUrl.appendingPathComponent("temp.br")
                manager.createFile(atPath: fileUrl.path, contents: data, attributes: nil)
                session.transferFile(fileUrl, metadata: nil)
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isWatchAppInstalled {
            syncWithAppleWatch()
        }
    }
    
    // Remote notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = NSData(data: deviceToken).description.replacingOccurrences(of:"<", with:"").replacingOccurrences(of:">", with:"").replacingOccurrences(of:" ", with:"")
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
                        defaults.set(true, forKey: "registeredForNotification")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.sendToken(token)
                }
            }
        }
    }
}
