//
//  PeopleToSave.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 2018/2/12.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import CoreData

final class PeopleToSave: NSManagedObject {
    
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
