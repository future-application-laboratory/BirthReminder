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
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    let storeDescription = NSPersistentStoreDescription(url: storeUrl!)
    storeDescription.shouldMigrateStoreAutomatically = true
    storeDescription.shouldInferMappingModelAutomatically = true
    configuration?(storeDescription, model)
    psc.addPersistentStore(with: storeDescription) { _, _ in }
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    return context
}

extension Data {
    func toPeopleToTransfer() -> PeopleToTransfer? {
        return NSKeyedUnarchiver.unarchiveObject(with: self) as? PeopleToTransfer
    }
}
