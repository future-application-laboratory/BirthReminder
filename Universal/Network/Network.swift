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
    case animes(requirements: String?)
    case animepic(withID: Int)
    case people(inAnimeID: Int)
    case personalPic(withID: Int)
    case notification(withToken: String)
    case contribution(animeName: String, animePicPack: PicPack, people: [People], contributorInfo: String)
}

enum SlackService {
    case feedback(content: String)
}

extension TCWQService: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return "https://www.tcwq.tech/api/BirthdayReminder/"
    }
    
    var path: String {
        switch self {
        case .animes(let requirements):
            if let requirement = requirements {
                return "animes/\(requirement)"
            } else {
                return "animes"
            }
        case .animepic(let id):
            return "image/anime/\(id)"
        case .people(let id):
            return "characters/\(id)"
        case .personalPic(let id):
            return "image/character/\(id)"
        case .notification(_):
            return "notification"
        case .contribution(_):
            return "contribution"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .notification(_):
            return .post
        case .contribution(_):
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
        case .contribution(let (animeName,picPack,people,contributorInfo)):
            // Refactor required here!
            let object:[String:Any] = ["anime":["name":animeName,"picPack":picPack.objectForContribution],"people":people.map{$0.objectForContribution},"contributorInfo":contributorInfo]
            return .requestParameters(parameters: object, encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
}

extension SlackService: TargetType {
    var baseURL: URL {
        return "https://hooks.slack.com"
    }
    
    var path: String {
        return "/services/T7RGQGPM3/B7RH06U2W/8PkGptdj864Y5rqwitfbWLM3"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .feedback(content: let content):
            return .requestParameters(parameters: ["text":content], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}

final class People: Mappable {
    var name = ""
    var stringedBirth = ""
    var picPack: PicPack?
    var id: Int?
    var status = false
    
    init(withName name: String, birth: String, picData: Data?, id: Int?) {
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
        return ["name":name,"birth":stringedBirth,"picPack":picPack!.objectForContribution]
    }
    
}

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

final class PicPack: Mappable {
    
    private var base64: String!
    var picData: NSData? {
        return NSData(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    var copyright: String!
    var pic: UIImage? {
        guard let data = picData else { return nil }
        return UIImage(data: data as Data)
    }
    var data: Data? {
        guard let pic = pic else { return nil }
        return UIImagePNGRepresentation(pic)
    }
    
    init?(picData: Data?) {
        guard let picData = picData else { return nil }
        base64 = picData.base64EncodedString()
    }
    
    required init?(map: Map) {
    }
    
    init?(image: UIImage, copyrightInfo: String) {
        guard let jpegData = UIImageJPEGRepresentation(image, 1.0) else { return nil }
        base64 = jpegData.base64EncodedString()
        copyright = copyrightInfo
    }
    
    func mapping(map: Map) {
        base64 <- map["pic"]
        copyright <- map["copyright"]
    }
    
    var objectForContribution: [String:Any] {
        return ["base64":base64,"copyright":copyright]
    }
    
}

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
