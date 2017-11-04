//
//  DatePickingRow.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 07/10/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import Eureka

public class DatePickingCell: Cell<String>, CellType, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let pickerView = UIPickerView()
    
    let monthDict = [
        1:31,
        2:29,
        3:31,
        4:30,
        5:31,
        6:30,
        7:31,
        8:31,
        9:30,
        10:31,
        11:30,
        12:31
    ]
    
    public override func setup() {
        super.setup()
        
        contentMode = .scaleAspectFit
        contentView.addSubview(pickerView)
        pickerView.snp.makeConstraints() { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 20))
        }
        height = { return 200 }
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if let birth = row.value {
            let month = birth[birth.startIndex..<birth.index(birth.startIndex, offsetBy: 2)]
            let day = birth[birth.index(birth.startIndex, offsetBy: 3)..<birth.endIndex]
            pickerView.selectRow(Int(month)! - 1, inComponent: 0, animated: false)
            pickerView.selectRow(Int(day)! - 1, inComponent: 1, animated: false)
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 12
        default:
            return monthDict[pickerView.selectedRow(inComponent: 0)+1]!
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (component == 0) ? NSLocalizedString("month\(row + 1)", comment: "localized month") : NSLocalizedString("day\(row + 1)", comment: "localized day")
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow _: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
        var day = String(pickerView.selectedRow(inComponent: 1) + 1)
        var month = String(pickerView.selectedRow(inComponent: 0) + 1)
        if day.count != 2 {
            day = "0" + day
        }
        if month.count != 2 {
            month = "0" + month
        }
        row.value = month + "-" + day
        row.updateCell()
    }
    
    
}

public final class DatePickingRow: Row<DatePickingCell>, RowType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
}
