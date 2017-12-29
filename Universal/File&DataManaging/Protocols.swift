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
