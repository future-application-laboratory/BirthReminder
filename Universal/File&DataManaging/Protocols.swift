//
//  Protocols.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 02/08/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectContextUsing: class {
    var context: NSManagedObjectContext! { get }
}

public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
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
