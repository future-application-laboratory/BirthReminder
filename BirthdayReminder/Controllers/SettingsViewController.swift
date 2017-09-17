//
//  SettingsViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 10/08/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import AcknowList

class SettingsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = .bar
        tableView.backgroundColor = .background
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let path = Bundle.main.path(forResource: "Pods-BirthdayReminder-acknowledgements", ofType: "plist")
            let controller = AcknowListViewController(acknowledgementsPlistPath: path)
            controller.acknowledgements! += [
                Acknow(title: "Material Icons", text: "Icons in the app are from Google Materail Icons.\nThe icons are available under the Apache License Version 2.0. We'd love attribution in your app's \"about\" screen, but it's not required. The only thing we ask is that you not re-sell these icons. https://material.io/icons/"),
                Acknow(title: "OpenCC", text: "The Traditional Chinese Localization are converted from Simplefied Chinese by OpenCC, which is licenced under Apache License 2.0 https://github.com/BYVoid/OpenCC"),
                Acknow(title: "Pics on the Server", text: "All the pics on the server are collected from the Internet, if you own the copyright/copyleft and don't want to see it here, please contact me at CaptainYukinoshitaHachiman@protonmail.com")
            ]
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

