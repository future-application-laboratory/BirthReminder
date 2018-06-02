//
//  ComplicationController.swift
//  WatchReminder Extension
//
//  Created by Jacky Yu on 25/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//
//  swiftlint:disable line_length

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let context = createDataMainContext()
    let request = PeopleToSave.sortedFetchRequest
    lazy var source: [PeopleToSave] = {
        do {
            let fetched = try context.fetch(request)
            return BirthComputer.peopleOrderedByBirthday(peopleToReorder: fetched)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    let supportedComplicationFamilies: [CLKComplicationFamily] = [.utilitarianLarge, .modularLarge]

    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(source.first?.birth.toDate()?.tomorrow)
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
    
    func getComplication(forFamily family: CLKComplicationFamily, withName name: String, stringDate: String) -> CLKComplicationTemplate? {
        guard let date = stringDate.toDate() else { return nil }
        return getComplication(forFamily: family, withName: name, date: date)
    }
    
    func getComplication(forFamily family: CLKComplicationFamily, withName name: String, date: Date) -> CLKComplicationTemplate? {
        switch family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            let dateProvider = CLKDateTextProvider(date: date, units: [.month,.day,.weekday])
            let nameProvider = CLKSimpleTextProvider(text: name)
            let leftDaysProvider = CLKRelativeDateTextProvider(date: date, style: .natural, units: [.month,.day,.hour,.minute,.second])
            template.headerTextProvider = nameProvider
            template.body1TextProvider = leftDaysProvider
            template.body2TextProvider = dateProvider
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString("dateStyleForComplications", comment: "MMM d")
            let localizedDate = formatter.string(from: date)
            let nameAndDateProvider = CLKSimpleTextProvider(text: "\(name) \(localizedDate)", shortText: name)
            template.textProvider = nameAndDateProvider
            return template
        default:
            return nil
        }
    }

}
