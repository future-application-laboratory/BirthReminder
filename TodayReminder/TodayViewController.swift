//
//  TodayViewController.swift
//  TodayReminder
//
//  Created by Jacky Yu on 25/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var data = [BirthPeople]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        //Read data in Realm into App Group
        var config = Realm.Configuration()
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.tech.tcwq.birthdayreminder")
        let realmUrl = container!.appendingPathComponent("default.realm")
        config.fileURL = realmUrl
        Realm.Configuration.defaultConfiguration = config
        
        
        data = BirthPeopleManager().getPersistedBirthPeople()
        data = BirthComputer().compute(withBirthdayPeople: data)
        
        nameLabel.text = data[0].name
        birthLabel.text = data[0].stringedBirth.toLocalizedDate()
        let picData = data[0].picData
        imageView.image = UIImage(data: picData)
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(.newData)
    }
    
}
