//
//  ComplicationController.swift
//  WatchReminder Extension
//
//  Created by Jacky Yu on 25/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let context = createDataMainContext()
    let request = PeopleToSave.sortedFetchRequest
    var source: [PeopleToSave]!
    
    let supportedComplicationFamilies:[CLKComplicationFamily] = [.utilitarianLarge,.modularLarge]
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(source.first?.birth.toDate()?.addingTimeInterval(86400))
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        guard !source.isEmpty else {
            handler(nil)
            return
        }
        let current = source[0]
        let template = getComplication(forFamily: complication.family, withName: current.name, stringDate: current.birth)
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template!)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let complication = getComplication(forFamily: complication.family, withName: "比企谷 八幡", stringDate: "08-08")
        handler(complication)
    }
    
    func getComplication(forFamily:CLKComplicationFamily,withName:String,stringDate:String) -> CLKComplicationTemplate? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard var date = formatter.date(from: BirthComputer.get(Year: .this) + "-" + stringDate) else {
            return nil
        }
        if date.timeIntervalSinceNow < -86400 {
            date = formatter.date(from: BirthComputer.get(Year: .next) + "-" + stringDate )!
        }
        return getComplication(forFamily: forFamily, withName: withName, date: date)
    }
    
    func getComplication(forFamily:CLKComplicationFamily,withName:String,date:Date) -> CLKComplicationTemplate? {
        switch forFamily {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            let dateProvider = CLKDateTextProvider(date: date, units: [.month,.day,.weekday])
            let nameProvider = CLKSimpleTextProvider(text: withName)
            let leftDaysProvider = CLKRelativeDateTextProvider(date: date, style: .natural, units: [.month,.day,.hour,.minute,.second])
            template.headerTextProvider = nameProvider
            template.body1TextProvider = leftDaysProvider
            template.body2TextProvider = dateProvider
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString("dateFormat",comment: "dateFormat")
            let localizedDate = formatter.string(from: date)
            let nameAndDateProvider = CLKSimpleTextProvider(text: withName + " " + localizedDate, shortText: localizedDate)
            template.textProvider = nameAndDateProvider
            return template
        default:
            return nil
        }
    }
    
    override init() {
        super.init()
        let fetched = try! context.fetch(request) as! [PeopleToSave]
        self.source = BirthComputer.compute(withBirthdayPeople: fetched)
    }
    
}
