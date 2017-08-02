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
    
    var data = [BirthPeople]()
    var status = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        //CoreData
        
        upDateContent()
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
    
    @IBAction func onChange(_ sender: Any) {
        status = !status
        upDateContent()
    }
    
    func upDateContent() {
        // TODO: CoreData
    }
}
