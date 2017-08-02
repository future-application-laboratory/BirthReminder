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

class BirthPeople {
    var name = ""
    var stringedBirth = ""
    var picData: Data?
    var picLink: String?
    var status = false
    
    init(withName: String,birth: String,picData: Data?,picLink: String?) {
        self.name = withName
        self.stringedBirth = birth
        self.picData = picData
        self.picLink = picLink
    }
    
    init() {
        
    }
}

class Anime {
    var id = -1
    var name = ""
    var startCharacter = 0
    var picLink = ""
    var pic:UIImage?
    
    init(withId: Int,name: String,startCharacter: Int,picLink: String,pic: UIImage) {
        self.id = withId
        self.name = name
        self.startCharacter = startCharacter
        self.picLink = picLink
        self.pic = pic
    }
    
}

// Core Data Persisting

public final class PeopleToSave: ManagedObject, ManagedObjectType {
    public static var entityName: String {
        return "People"
    }

    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var birth: String
    @NSManaged public private(set) var picData: Data
}

public class ManagedObject: NSManagedObject {
    
}

private let storeUrl = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.tech.tcwq.birthdayreminder")?.appendingPathComponent("Data.br")

public func createDataMainContext() -> NSManagedObjectContext {
    let bundles = [Bundle(for: PeopleToSave.self)]
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
        fatalError("Model not found")
    }
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    return context
}
