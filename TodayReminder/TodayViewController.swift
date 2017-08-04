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
    var data = [PeopleToSave]()
    var status = true
    //CoreData
    let context = createDataMainContext()
    
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
        let request = PeopleToSave.sortedFetchRequest
        data = try! context.fetch(request) as! [PeopleToSave]
        data = BirthComputer().compute(withBirthdayPeople: data)
        guard !data.isEmpty else {
            view.subviews.forEach { view in
                view.isHidden = true
            }
            emptyLabel.isHidden = false
            return
        }
        view.subviews.forEach { view in
            view.isHidden = false
        }
        emptyLabel.isHidden = true
        let current = data[0]
        nameLabel.text = current.name
        let birth = current.birth
        birthLabel.text = status ? birth.toLocalizedDate(withStyle: .long) : birth.toLeftDays()
        imageView.image = UIImage(data: current.picData)
    }
    
}
