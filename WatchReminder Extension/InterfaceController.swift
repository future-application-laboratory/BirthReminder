//
//  InterfaceController.swift
//  WatchReminder Extension
//
//  Created by Jacky Yu on 25/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    var status = false
    var tableData = [BirthPeople]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        reloadDataSource()
        reloadTable()
    }
    
    override func willActivate() {
        let defaults = UserDefaults()
        let isUpdated = defaults.bool(forKey: "dataBaseIsUpdated")
        if isUpdated {
            reloadDataSource()
            reloadTable()
            defaults.set(false, forKey: "dataBaseIsUpdated")
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        status = !status
        for times in 0..<table.numberOfRows {
            if let controller = table.rowController(at: times) as? TableRowController {
                let currentDate = tableData[times].stringedBirth
                controller.birthLabel.setText(status ? currentDate.toLeftDays() : currentDate.toLocalizedDate(withStyle: .medium))
            }
        }
    }
    
    func reloadTable() {
        table.setNumberOfRows(tableData.count, withRowType: "tableRowController")
        
        for times in 0..<table.numberOfRows {
            if let controller = table.rowController(at: times) as? TableRowController {
                let currentData = tableData[times]
                controller.nameLabel.setText(currentData.name)
                controller.birthLabel.setText(currentData.stringedBirth.toLocalizedDate(withStyle: .medium))
                controller.image.setImageData(currentData.picData)
            }
        }
    }
    
    func reloadDataSource() {
        tableData = BirthPeopleManager().getPersistedBirthPeople()
        tableData = BirthComputer().compute(withBirthdayPeople: tableData)
    }
    
}
