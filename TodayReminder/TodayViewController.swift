//
//  TodayViewController.swift
//  TodayReminder
//
//  Created by Jacky Yu on 25/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var status = true
    // CoreData
    let context = createDataMainContext()
    var current: PeopleToSave?
    var isEmpty: Bool {
        return current == nil
    }
    let request = PeopleToSave.sortedFetchRequest
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = 10

        upDateContent()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(.newData)
    }
    
    @IBAction func onChange(_ sender: Any) {
        status = !status
        upDateContent()
    }
    
    func upDateContent() {
        fetchData()
        guard current != nil else {
            return
        }
        
        nameLabel.text = current!.name
        let birth = current!.birth
        birthLabel.text = status ? birth.toLocalizedDate() : birth.toLeftDays()
        if let data = current?.picData {
            imageView.image = UIImage(data: data)
        }
    }
    
    func fetchData() {
        let fetched = try! context.fetch(request)
        if !fetched.isEmpty {
            let people = fetched
            current = BirthComputer.peopleOrderedByBirthday(peopleToReorder: people)[0]
        }
        nameLabel.isHidden = isEmpty
        birthLabel.isHidden = isEmpty
        imageView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }
    
}
