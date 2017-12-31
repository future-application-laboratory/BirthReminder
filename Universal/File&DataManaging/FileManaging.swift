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


// Core Data Persisting

final class PeopleToSave: ManagedObject {
    
    @NSManaged public var name: String
    @NSManaged public var birth: String
    @NSManaged public var picData: Data?
    @NSManaged public var picCopyright: String?
    @NSManaged public var shouldSync: Bool
    @NSManaged private var identifier: UUID?
    
    public var uuid: UUID {
        if let uuid = identifier {
            return uuid
        } else {
            let uuid = UUID()
            identifier = uuid
            return uuid
        }
    }
    
    static func insert(into context:NSManagedObjectContext, name: String, birth: String, picData: Data?, picCopyright: String? = nil, shouldSync: Bool, identifier: UUID? = nil) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let person = NSManagedObject(entity: entity!, insertInto: context)
        person.setValue(name, forKey: "name")
        person.setValue(birth, forKey: "birth")
        person.setValue(picData, forKey: "picData")
        person.setValue(shouldSync, forKey: "shouldSync")
        person.setValue(identifier ?? UUID(), forKey: "identifier")
        person.setValue(picCopyright, forKey: "picCopyright")
        
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
    
    public static var sortedFetchRequest: NSFetchRequest<PeopleToSave> {
        let request = NSFetchRequest<PeopleToSave>(entityName: "People")
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}

typealias ManagedObject = NSManagedObject

private let storeUrl = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.tech.tcwq.birthdayreminder")?.appendingPathComponent("Data.br")

public func createDataMainContext() -> NSManagedObjectContext {
    let bundles = [Bundle(for: PeopleToSave.self)]
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
        fatalError("Model not found")
    }
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: [NSMigratePersistentStoresAutomaticallyOption:true,NSInferMappingModelAutomaticallyOption:true])
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    return context
}

@objc(PeopleToTransfer) // MagicCode, don't remove it

class PeopleToTransfer: NSObject, NSCoding {
    var name: String
    var birth: String
    var picData: Data?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(birth, forKey: "birth")
        aCoder.encode(picData, forKey: "picData")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String,
            let birth = aDecoder.decodeObject(forKey: "birth") as? String,
            let picData = aDecoder.decodeObject(forKey: "picData") as? Data?
            else { return nil }
        self.init(withName: name, birth: birth, picData: picData)
    }
    
    init(withName: String, birth: String, picData: Data?) {
        self.name = withName
        self.birth = birth
        self.picData = picData
    }
    
    public var encoded: Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
}

extension Data {
    func toPeopleToTransfer() -> PeopleToTransfer? {
        return NSKeyedUnarchiver.unarchiveObject(with: self) as? PeopleToTransfer
    }
}
