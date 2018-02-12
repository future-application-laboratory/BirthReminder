//
//  People.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 2018/2/12.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import ObjectMapper

final class People: Mappable {
    var name = ""
    var stringedBirth = ""
    var picPack: PicPack?
    var id: Int?
    var status = false
    
    init(withName name: String, birth: String, picData: Data, id: Int?) {
        self.name = name
        self.stringedBirth = birth
        self.picPack = PicPack(picData: picData)
        self.id = id
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        stringedBirth <- map["birth"]
        id <- map["id"]
    }
    
    var objectForContribution: [String:Any] {
        return ["name":name,"birth":stringedBirth,"picPack":picPack!.objectForContribution!]
    }
    
}
