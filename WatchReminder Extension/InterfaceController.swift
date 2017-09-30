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

class InterfaceController: WKInterfaceController, NSFetchedResultsControllerDelegate, ReloadControllerDelegate {
    
    @IBOutlet var emptyLabel: WKInterfaceLabel!
    @IBOutlet var table: WKInterfaceTable!
    var status = false
    var tableData: [PeopleToSave]!
    var delegate: ExtensionDelegate {
        return WKExtension.shared().delegate as! ExtensionDelegate
    }
    var context: NSManagedObjectContext {
        return delegate.context
    }
    let request = PeopleToSave.sortedFetchRequest
    var first = true
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        delegate.reloadController.delegate = self
        reload()
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
        guard !tableData.isEmpty else {
            emptyLabel.setHidden(false)
            table.setHidden(true)
            return
        }
        
        tableData = BirthComputer.peopleOrderedByBirthday(peopleToReorder: tableData)
        
        table.setNumberOfRows(tableData.count, withRowType: "tableRowController")
        
        for times in 0..<table.numberOfRows {
            if let controller = table.rowController(at: times) as? TableRowController {
                let currentData = tableData[times]
                controller.nameLabel.setText(currentData.name)
                controller.birthLabel.setText(currentData.birth.toLocalizedDate(withStyle: .medium))
                controller.image.setImageData(currentData.picData)
            }
        }
        
        emptyLabel.setHidden(true)
        table.setHidden(false)
    }
    
    func reload() {
        tableData = try! context.fetch(request)
        reloadTable()
    }
    
}

protocol ReloadControllerDelegate {
    func reload()
}
