//
//  PeopleToTransfer.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 2018/2/12.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation

// MagicCode, DO NOT REMOVE IT
// For detail, see: https://stackoverflow.com/questions/29472935/cannot-decode-object-of-class
@objc(PeopleToTransfer)


final class PeopleToTransfer: NSObject, NSCoding {
    var name: String
    var birth: String
    var picData: Data?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(birth, forKey: "birth")
        aCoder.encode(picData, forKey: "picData")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String,
            let birth = aDecoder.decodeObject(forKey: "birth") as? String,
            let picData = aDecoder.decodeObject(forKey: "picData") as? Data?
            else { return nil }
        self.init(withName: name, birth: birth, picData: picData)
    }
    
    init(withName: String, birth: String, picData: Data?) {
        self.name = withName
        self.birth = birth
        self.picData = picData
    }
    
    public var encoded: Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
}
