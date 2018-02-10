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
    private let pickerView = UIPickerView()
    private let daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    public override func setup() {
        super.setup()
        
        contentMode = .scaleAspectFit
        contentView.addSubview(pickerView)
        pickerView.snp.makeConstraints() { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 20))
        }
        height = { 200 }
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
            return daysInMonth[pickerView.selectedRow(inComponent: 0)]
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM"
            let date = formatter.date(from: "\(row + 1)")!
            formatter.dateFormat = "MMMM"
            return formatter.string(from: date)
        } else {
            return "\(row + 1)"
        }
    }

    // FIXME: Displays wrong date when swipe too fast.
    public func pickerView(_ pickerView: UIPickerView, didSelectRow _: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
        row.value = String(format: "%02d-%02d",
                           pickerView.selectedRow(inComponent: 0) + 1,
                           pickerView.selectedRow(inComponent: 1) + 1)
        row.updateCell()
    }
}

public final class DatePickingRow: Row<DatePickingCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
