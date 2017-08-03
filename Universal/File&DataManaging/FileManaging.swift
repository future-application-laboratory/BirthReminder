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

public final class PeopleToSave: ManagedObject {
    
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var birth: String
    @NSManaged public private(set) var picData: Data
    
    static func insert(into context:NSManagedObjectContext, name: String, birth: String, picData: Data?) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let person = NSManagedObject(entity: entity!, insertInto: context)
        person.setValue(name, forKey: "name")
        person.setValue(birth, forKey: "birth")
        person.setValue(picData, forKey: "picData")
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to save: \(error)")
        }
    }
    
}

extension PeopleToSave: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: false)]
    }
    
    public static var entityName: String {
        return "People"
    }
    
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


