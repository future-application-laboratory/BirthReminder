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
    private var status = false
    private var tableData: [PeopleToSave]!
    private var delegate: ExtensionDelegate {
        return WKExtension.shared().delegate as! ExtensionDelegate
    }
    private var context: NSManagedObjectContext {
        return delegate.context
    }
    private let request = PeopleToSave.sortedFetchRequest
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        delegate.reloadController.delegate = self
        reload()
    }
    
    private func reloadTable() {
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
                controller.birthLabel.setText(currentData.birth.toLocalizedDate())
                controller.image.setImageData(currentData.picData)
            }
        }
        
        emptyLabel.setHidden(true)
        table.setHidden(false)
    }
    
    func reload() {
        tableData = (try? context.fetch(request)) ?? []
        reloadTable()
    }
    
    @IBAction func switchLeftAndDate() {
        status = !status
        for times in 0..<table.numberOfRows {
            if let controller = table.rowController(at: times) as? TableRowController {
                let currentDate = tableData[times].birth
                controller.birthLabel.setText(status ? currentDate.toLeftDays() : currentDate.toLocalizedDate())
            }
        }
    }
    
}

protocol ReloadControllerDelegate {
    func reload()
}
