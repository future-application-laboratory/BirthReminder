//
//  FileManaging.swift
//  BirthdayReminder
//
//  Created by CaptainHikigayaHachiman on 17/06/2017.
//Copyright © 2017 CaptainHikigayaHachiman. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class BirthPeople:Object {
    @objc dynamic var name = ""
    @objc dynamic var stringedBirth = ""
    @objc dynamic var picData = Data()
    @objc dynamic var picLink = ""
    @objc dynamic var status = false
}

class Anime {
    var id = -1
    var name = ""
    var startCharacter = 0
    var picLink = ""
    var pic:UIImage?
    init(withId:Int,name:String,startCharacter:Int,picLink:String,pic:UIImage) {
        self.id = withId
        self.name = name
        self.startCharacter = startCharacter
        self.picLink = picLink
        self.pic = pic
    }
}

class BirthPeopleManager {
    let realmQueue = DispatchQueue(label: "Realm", qos: .background)
    var realm:Realm!
    func persist(Person:BirthPeople) {
        let realm = try! Realm()
        try! realm.write{
            realm.add(Person)
            print(realm.configuration.fileURL!)
            print(Person)
        }
    }
    
    func getPersistedBirthPeople() -> [BirthPeople] {
        var finalResults = [BirthPeople]()
        var status = false
        realmQueue.async {
            let objects = self.realm.objects(BirthPeople.self)
            objects.forEach { object in
                let name = object.name
                let birth = object.stringedBirth
                let data = object.picData
                let person = self.creatBirthPeople(name: name,stringedBirth: birth,picData: data)
                finalResults.append(person)
            }
            status = true
        }
        while !status {
            Thread.sleep(forTimeInterval: 0.1)
        }
        return finalResults
    }
    
    func creatBirthPeople(name:String,stringedBirth:String,pic:UIImage) -> BirthPeople {
        let data = UIImagePNGRepresentation(pic) ?? Data()
        return BirthPeople(value: ["name":name,"stringedBirth":stringedBirth,"picData":data])
    }
    
    func creatBirthPeople(name:String,stringedBirth:String,picData:Data) -> BirthPeople {
        return BirthPeople(value: ["name":name,"stringedBirth":stringedBirth,"picData":picData])
    }
    
    func creatBirthPeople(name:String,stringedBirth:String,picLink:String) -> BirthPeople {
        return BirthPeople(value: ["name":name,"stringedBirth":stringedBirth,"picLink":picLink])
    }
    
    func deleteBirthPeople(whichFollows:String) {
        self.realmQueue.async {
            if let objectGoingToDelete = self.realm.objects(BirthPeople.self).filter(whichFollows).first {
                try! self.realm.write {
                    self.realm.delete(objectGoingToDelete)
                }
            }
        }
    }
    
    init() {
        realmQueue.async {
            self.realm = try! Realm()
        }
    }
    
    init(withUrl:URL) {
        realmQueue.async {
            do{
                self.realm = try Realm(fileURL: withUrl)
            }catch{
                print(error)
            }
        }
    }
    
}

