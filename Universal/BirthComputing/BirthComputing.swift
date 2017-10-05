//
//  BirthComputing.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 23/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation

class BirthComputer {
    typealias BirthPeopleWithIntervalTime = [(people:PeopleToSave,interval:TimeInterval)]
    
    static func compute(withBirthdayPeople:[PeopleToSave]) -> [PeopleToSave] {
        
        var birthPeopleWithIntervalTime = BirthPeopleWithIntervalTime()
        
        //Get the interval time
        withBirthdayPeople.forEach { person in
            let birth = person.birth
            let interval = putIntoDate(with: birth)?.timeIntervalSinceNow ?? 0
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
        
        var result = [PeopleToSave]()
        for times in 0..<birthPeopleWithIntervalTime.count {
            result.append(birthPeopleWithIntervalTime[times].people)
        }
        return result
    }
    
    static func putIntoDate(with:String) -> Date? {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy-MM-dd"
        let date = formmater.date(from: get(Year: .this) + "-" + with)
        return date
    }
    
    static func get(Year:YearType) -> String {
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
    
    func toLocalizedDate(withStyle:DateFormatter.Style) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: BirthComputer.get(Year: .this) + "-" + self) {
            if date.timeIntervalSinceNow < -86400 {
                let nextDate = formatter.date(from: BirthComputer.get(Year: .next) + "-" + self)!
                formatter.dateStyle = withStyle
                return formatter.string(from: nextDate)
            }else{
                formatter.dateStyle = withStyle
                return formatter.string(from: date)
            }
        }
        return nil
    }
    
    func toLeftDays() -> String? {
        let formatter = DateFormatter()
        var leftDays:TimeInterval
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: BirthComputer.get(Year: .this) + "-" + self) {
            leftDays = date.timeIntervalSinceNow / (24 * 60 * 60)
            if leftDays < -1 {
                let nextDate = formatter.date(from: BirthComputer.get(Year: .next) + "-" + self)!
                leftDays = nextDate.timeIntervalSinceNow / (24 * 60 * 60)
            }else if (leftDays >= -1) && (leftDays < 0) {
                return "Today"
            }
        }else{
            return nil
        }
        if leftDays.truncatingRemainder(dividingBy: 1) != 0 {
            leftDays = TimeInterval(Int(leftDays) + 1)
        }
        switch leftDays {
        case 0:
            return NSLocalizedString("today", comment: "today")
        case 1:
            return NSLocalizedString("tomorrow", comment: "tomorrow")
        case 2:
            return NSLocalizedString("dayAfterTomorrow", comment: "dayAfterTomorrow")
        default:
            return NSLocalizedString("daysLeft-", comment: "daysLeft-") + "\(Int(leftDays))" + NSLocalizedString("-daysLeft", comment: "-daysLeft")
        }
    }
    
    func toDate(withYear:BirthComputer.YearType) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: BirthComputer.get(Year: withYear) + "-" + self)
    }
    
    func toDate() -> Date? {
        guard let date = self.toDate(withYear: .this) else {
            return nil
        }
        if date.timeIntervalSinceNow < -86400 {
            return self.toDate(withYear: .next)
        } else {
            return date
        }
    }
    
}

extension Array where Element: PeopleToSave {
    mutating func sort() {
        self = BirthComputer.compute(withBirthdayPeople: (self as [PeopleToSave])) as! Array
    }
}
