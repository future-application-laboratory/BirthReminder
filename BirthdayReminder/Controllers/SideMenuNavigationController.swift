//
//  SideMenuNavigationController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuNavigationController: UISideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.titleTextAttributes = [.foregroundColor:UIColor.title]
    }
    
}
