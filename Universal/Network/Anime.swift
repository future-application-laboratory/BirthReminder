//
//  Anime.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 2018/2/12.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import ObjectMapper

final class Anime: Mappable {
    var id = -1
    var name = ""
    var picPack: PicPack?

    init(withId id: Int, name: String) {
        self.id = id
        self.name = name
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
    }
}
