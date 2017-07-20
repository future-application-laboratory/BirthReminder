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
    @objc dynamic var name:String = ""
    @objc dynamic var stringedBirth:String = ""
    @objc dynamic var picData:Data = Data()
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
    let realmQueue = DispatchQueue(label: "Realm", qos: .userInteractive)
    
    func persist(Person:BirthPeople) {
        let realm = try! Realm()
        try! realm.write{
            realm.add(Person)
            print(realm.configuration.fileURL!)
            print(Person)
        }
    }
    
    func getPersistedBirthPeople() -> [BirthPeople]{
        var people = [BirthPeople]()
        var status = false
        realmQueue.async {
            let realm = try! Realm()
            let objects = realm.objects(BirthPeople.self)
            people = objects.map {$0}
            status = true
        }
        while !status {
            Thread.sleep(forTimeInterval: 0.1)
        }
        return people
    }
    
    func creatBirthPeople(name:String,stringedBirth:String,pic:UIImage?) -> BirthPeople {
        var person:BirthPeople?
        let data = UIImagePNGRepresentation(pic ?? UIImage()) ?? Data()
        var status = false
        realmQueue.async {
            person = BirthPeople(value: ["name":name,"stringedBirth":stringedBirth,"picData":data])
            status = true
        }
        while !status {
            Thread.sleep(forTimeInterval: 0.1)
        }
        return person!
    }
    
    func creatBirthPeople(name:String,stringedBirth:String,picData:Data) -> BirthPeople {
        var person:BirthPeople?
        var status = false
        realmQueue.async {
            person = BirthPeople(value: ["name":name,"stringedBirth":stringedBirth,"picData":picData])
            status = true
        }
        while !status {
            Thread.sleep(forTimeInterval: 0.1)
        }
        return person!
    }
    
    func creatBirthPeople(name:String,stringedBirth:String,picLink:String) -> BirthPeople {
        var person:BirthPeople?
        var status = false
        realmQueue.async {
            person = BirthPeople(value: ["name":name,"stringedBirth":stringedBirth,"picLink":picLink])
            status = true
        }
        while !status {
            Thread.sleep(forTimeInterval: 0.1)
        }
        return person!
    }
    
}

