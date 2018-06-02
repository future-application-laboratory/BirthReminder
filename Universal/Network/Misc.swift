//
//  Network.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 13/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Moya

protocol CopyrightViewing: class {
    func showCopyrightInfo(_ info: String)
}

class NetworkController {

    static let networkQueue = DispatchQueue(label: "network", qos: .userInitiated)

    static let provider = MoyaProvider<TCWQService>()

}

extension URL: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
}
