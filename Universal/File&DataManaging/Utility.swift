//
//  FileManaging.swift
//  BirthdayReminder
//
//  Created by CaptainHikigayaHachiman on 17/06/2017.
//Copyright © 2017 CaptainHikigayaHachiman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let storeUrl = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.tech.tcwq.birthdayreminder")?.appendingPathComponent("Data.br")

public func createDataMainContext(with configuration: ((NSPersistentStoreDescription, NSManagedObjectModel) -> Void)? = nil) -> NSManagedObjectContext {
    let bundles = [Bundle(for: PeopleToSave.self)]
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
        fatalError("Model not found")
    }
    let storeDescription = NSPersistentStoreDescription(url: storeUrl!)
    storeDescription.shouldMigrateStoreAutomatically = true
    storeDescription.shouldInferMappingModelAutomatically = true
    configuration?(storeDescription, model)
    #if os(iOS)
        let container = NSPersistentCloudKitContainer(name: "BR", managedObjectModel: model)
        storeDescription.cloudKitContainerOptions = .init(containerIdentifier: "iCloud.tech.TCWQ.BirthReminder")
    #else
        let container = NSPersistentContainer(name: "BR", managedObjectModel: model)
    #endif
    container.persistentStoreDescriptions = [storeDescription]
    container.loadPersistentStores { (_, error) in
        guard error == nil else {
            fatalError(error!.localizedDescription)
        }
    }
    let context = container.viewContext
    #if os(iOS)
    context.automaticallyMergesChangesFromParent = true
    #endif
    return context
}
