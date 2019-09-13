//
//  PeopleToTransfer.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 2018/2/12.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation

struct PeopleToTransfer: Codable {
    var name: String
    var birth: String
    var picData: Data?
}
