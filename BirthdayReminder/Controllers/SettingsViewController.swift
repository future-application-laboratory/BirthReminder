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
        tableView.backgroundColor = UIColor.flatGreen
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let path = Bundle.main.path(forResource: "Pods-BirthdayReminder-acknowledgements", ofType: "plist")
            let controller = AcknowListViewController(acknowledgementsPlistPath: path)
            
            controller.tableView.backgroundColor = UIColor.flatGreen
            controller.tableView.visibleCells.forEach { cell in
                cell.backgroundColor = UIColor.flatGreen
            }
            controller.title = NSLocalizedString("license", comment: "license")
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

