//
//  ExtensionDelegate.swift
//  WatchReminder Extension
//
//  Created by Jacky Yu on 25/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import WatchKit
import WatchConnectivity
import CoreData

class ExtensionDelegate: NSObject , WKExtensionDelegate , WCSessionDelegate {
    
    var context: NSManagedObjectContext!
    var frc: NSFetchedResultsController<NSFetchRequestResult>!
    
    func applicationDidFinishLaunching() {
        
        //Watch Connectivity Configuration
        let session = WCSession.default()
        session.delegate = self
        session.activate()
        
        try! frc.performFetch()
        
        let defaults = UserDefaults()
        defaults.set(true, forKey: "startup")
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("Got file")
        let defaults = UserDefaults()
        defaults.set(true, forKey: "dataBaseIsUpdated")
        
        try!frc.performFetch()
        frc.fetchedObjects?.forEach { object in
            context.delete(object as! NSManagedObject)
        } //Delete all the previous objects
        
        (NSKeyedUnarchiver.unarchiveObject(withFile: file.fileURL.path) as! [Dictionary<String, Any>]).forEach { person in
            PeopleToSave.insert(into: context, name: person["name"] as! String, birth: person["birth"] as! String, picData: person["picData"] as! Data?)
        }//Add new objects
        
        //Update the complications
        let server = CLKComplicationServer.sharedInstance()
        server.activeComplications?.forEach { complication in
            server.reloadTimeline(for: complication)
        }
    }
    
    override init() {
        super.init()
        context = createDataMainContext()
        frc = NSFetchedResultsController(fetchRequest: PeopleToSave.sortedFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
}
