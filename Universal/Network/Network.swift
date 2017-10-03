//
//  Network.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 13/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import Moya

enum TCWQService {
    case animes
    case animepic(withID: Int)
    case people(inAnimeID: Int)
    case personalPic(withID: Int, inAnime: Int)
    case notification(withToken: String)
}

extension TCWQService: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return URL(string: "https://www.tcwq.tech/api/BirthdayReminder/")!
    }
    
    var path: String {
        switch self {
        case .animes:
            return "animes"
        case .animepic(let id):
            return "images/\(id)/anime.jpg"
        case .people(let id):
            return "config/\(id)"
        case .personalPic(let (id,animeID)):
            return "images/\(animeID)/\(id).jpg"
        case .notification(_):
            return "notification"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .notification(_):
            return .post
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .notification(let token):
            return .requestParameters(parameters: ["token":token], encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
}

final class People: Mappable {
    var name = ""
    var stringedBirth = ""
    var picData: Data?
    var id: Int?
    var status = false
    
    init(withName name: String,birth: String,picData: Data?,id: Int?) {
        self.name = name
        self.stringedBirth = birth
        self.picData = picData
        self.id = id
    }
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        stringedBirth <- map["birth"]
        id <- map["id"]
    }
}

final class Anime: Mappable {
    var id = -1
    var name = ""
    var pic:UIImage?
    
    init(withId id: Int,name: String,pic: UIImage?) {
        self.id = id
        self.name = name
        self.pic = pic
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
    }
}


class NetworkController {
    
    static let networkQueue = DispatchQueue(label: "network", qos: .userInitiated)
    
    static let provider = MoyaProvider<TCWQService>()
    
}
