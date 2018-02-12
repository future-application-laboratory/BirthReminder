//
//  Moya.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 2018/2/12.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

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
        return "https://www.tcwq.tech/api/BirthReminder/"
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
            let defaults = UserDefaults.standard
            let token = defaults.string(forKey: "remoteToken") ?? "nil"
            
            let object:[String:Any] = ["anime":["name":animeName,"picPack":picPack.objectForContribution!],"people":people.map{$0.objectForContribution},"contributorInfo":contributorInfo,"token":token]
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
