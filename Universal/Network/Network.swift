//
//  Network.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 13/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation
import UIKit
import Just
import SwiftyJSON

class ReminderDataNetworkController {
    let networkQueue = DispatchQueue(label: "network", qos: .default)
    
    func get(PicFromUrl:URL) -> UIImage {
        var image = UIImage()
        do{
            let data = try Data(contentsOf: PicFromUrl)
            image = UIImage(data: data)!
        }catch{
            print("Failed to get image from link",PicFromUrl)
        }
        return image
    }
    
    func get(PicFromStringedUrl:String) -> UIImage {
        if let url = URL(string: PicFromStringedUrl) {
            return get(PicFromUrl: url)
        }
        return UIImage()
    }
    
    func getListOfAnimes() -> [Anime] {
        var finalResult = [Anime]()
        
        let gottenData = Just.get("https://www.tcwq.tech/api/birthdayreminder/animes")
        if let dataContent = gottenData.content {
            let json = JSON(dataContent)
            for data in json {
                let id = Int(data.0)!
                let detail = data.1
                let name = detail["name"].string!
                let link = detail["picLink"].string!
                let startCharacter = Int(detail["startCharacter"].string!)!
                let anime = Anime(withId: id, name: name, startCharacter: startCharacter, picLink: link, pic: UIImage())
                finalResult.append(anime)
            }
        }
        
        return finalResult
    }
    
    func getCharacters(InAnimeWithId:Int,StartAt:Int) -> [BirthPeople] {
        var finalResult = [BirthPeople]()
        
        var stringedAnimeId = String(InAnimeWithId)
        while stringedAnimeId.characters.count != 3 {
            stringedAnimeId = "0" + stringedAnimeId
        }
        
        var stringedStartPosition = String(StartAt)
        while stringedStartPosition.characters.count != 5 {
            stringedStartPosition = "0" + stringedStartPosition
        }
        
        let gottenData = Just.get("https://www.tcwq.tech/api/birthdayReminder/Config/" + stringedAnimeId + stringedStartPosition)
        if let dataContent = gottenData.content {
            let json = JSON(data: dataContent)
            for data in json {
                let name = data.1["name"].string!
                let birth = data.1["birth"].string!
                let picLink = data.1["picLink"].string!
                let object = BirthPeople(withName: name, birth: birth, picData: nil, picLink: picLink)
                finalResult.append(object)
            }
        }
        return finalResult
    }
    
}
