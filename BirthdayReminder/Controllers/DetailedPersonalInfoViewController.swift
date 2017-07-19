//
//  DetailedPersonalInfoViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/07/2017.
//  Copyright © 2017 CaptainYukin oshitaHachiman. All rights reserved.
//

import UIKit

class DetailedPersonalInfoViewController: UIViewController {
    var personalData = BirthPeople()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(personalData)
    }
    
}
