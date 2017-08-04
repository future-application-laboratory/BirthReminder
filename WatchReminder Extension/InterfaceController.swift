//
//  InterfaceController.swift
//  WatchReminder Extension
//
//  Created by Jacky Yu on 25/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class InterfaceController: WKInterfaceController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var table: WKInterfaceTable!
    var status = false
    var tableData: [PeopleToSave]!
    var delegate: ExtensionDelegate {
        return WKExtension.shared().delegate as! ExtensionDelegate
    }
    var context: NSManagedObjectContext {
        return delegate.context
    }
    var frc: NSFetchedResultsController<NSFetchRequestResult> {
        return delegate.frc
    }
    let request = PeopleToSave.sortedFetchRequest
    
    override init() {
        super.init()
        frc.delegate = self
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupDataSource()
        reloadTable()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        status = !status
        for times in 0..<table.numberOfRows {
            if let controller = table.rowController(at: times) as? TableRowController {
                let currentDate = tableData[times].birth
                controller.birthLabel.setText(status ? currentDate.toLeftDays() : currentDate.toLocalizedDate(withStyle: .medium))
            }
        }
    }
    
    func reloadTable() {
        tableData = BirthComputer().compute(withBirthdayPeople: tableData)
        
        table.setNumberOfRows(tableData.count, withRowType: "tableRowController")
        
        for times in 0..<table.numberOfRows {
            if let controller = table.rowController(at: times) as? TableRowController {
                let currentData = tableData[times]
                controller.nameLabel.setText(currentData.name)
                controller.birthLabel.setText(currentData.birth.toLocalizedDate(withStyle: .medium))
                controller.image.setImageData(currentData.picData)
            }
        }
    }
    
    func setupDataSource() {
        tableData = try! context.fetch(request) as! [PeopleToSave]
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableData.append(anObject as! PeopleToSave)
        default:
            break
        }
        reloadTable()
    }
    
}
