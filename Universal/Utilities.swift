//
//  Utilities.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 15/12/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation

extension URL {
    static var temporary: URL {
        return URL(fileURLWithPath:NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
    }
}
