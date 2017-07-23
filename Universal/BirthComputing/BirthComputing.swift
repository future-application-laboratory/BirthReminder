//
//  BirthComputing.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 23/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation

class BirthComputer {
    typealias BirthPeopleWithIntervalTime = [(people:BirthPeople,interval:TimeInterval)]
    
    func compute(withBirthdayPeople:[BirthPeople]) -> [BirthPeople] {
        
        var birthPeopleWithIntervalTime = BirthPeopleWithIntervalTime()
        
        //Get the interval time
        withBirthdayPeople.forEach { person in
            let birth = person.stringedBirth
            let interval = putIntoDate(with: birth)!.timeIntervalSinceNow
            birthPeopleWithIntervalTime.append((people: person,interval: interval))
        }
        
        //Bubble sort
        for _ in 0..<withBirthdayPeople.count {
            for times in 0..<(withBirthdayPeople.count - 1) {
                if birthPeopleWithIntervalTime[times + 1].interval < birthPeopleWithIntervalTime[times].interval {
                    let temp = birthPeopleWithIntervalTime[times]
                    birthPeopleWithIntervalTime[times] = birthPeopleWithIntervalTime[times + 1]
                    birthPeopleWithIntervalTime[times + 1] = temp
                }
            }
        }
        
        /*Put the births in the past (time interval < -86400) at last
         1day == -86400s,
         so if time interval is in -86400...0,
         then it is today,but not in the past*/
        let peopleHaveBirthsInThePast = birthPeopleWithIntervalTime.filter { person in
            person.interval < -86400
        }
        birthPeopleWithIntervalTime = birthPeopleWithIntervalTime.filter { person in
            person.interval >= -86400
        }
        birthPeopleWithIntervalTime.append(contentsOf: peopleHaveBirthsInThePast)
        
        var result = [BirthPeople]()
        for times in 0..<birthPeopleWithIntervalTime.count {
            result.append(birthPeopleWithIntervalTime[times].people)
        }
        return result
    }
    
    func putIntoDate(with:String) -> Date? {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy-MM-dd"
        let date = formmater.date(from: get(Year: .this) + "-" + with)
        return date
    }
    
    func get(Year:YearType) -> String {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy"
        switch Year {
        case .this:
            return formmater.string(from: Date())
        default:
            let intYear = Int(get(Year: .this))!
            return String(intYear + 1)
        }
    }
    
    enum YearType {
        case this
        case next
    }
}

extension String {
    func toFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var date = formatter.date(from: BirthComputer().get(Year: .this) + "-" + self)!
        if date.timeIntervalSinceNow < -86400 {
            date = formatter.date(from: BirthComputer().get(Year: .next) + "-" + self)!
        }
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

