//
//  ShouldReload.swift
//  WatchReminder Extension
//
//  Created by Captain雪ノ下八幡 on 2018/5/12.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation

extension Date {
    
    fileprivate static var lastReload: Date? {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let lastDate = UserDefaults.standard.string(forKey: "lastReload") ?? ""
            return formatter.date(from: lastDate)
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            UserDefaults.standard.set(formatter.string(from: newValue ?? Date()), forKey: "lastReload")
        }
    }
    
    fileprivate static func updateReloadingRecord() {
        lastReload = Date()
    }
    
}

extension InterfaceController {
    
    var needToUpdateSorting: Bool {
        if let last = Date.lastReload {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year,.month,.day], from: last)
            if calendar.date(last, matchesComponents: components) {
                return false
            }
        }
        return true
    }
    
}
