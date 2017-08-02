//
//  Protocols.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 02/08/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation
import CoreData

public protocol ManagedObjectContextSettable: class {
    var context: NSManagedObjectContext! { get set }
}

public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension ManagedObjectType {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    public static var sortedFetchRequest: NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}
