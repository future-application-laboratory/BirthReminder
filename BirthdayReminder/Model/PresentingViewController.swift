//
//  PresentingViewController.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 10/12/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation
import UIKit

class PresentingViewController {
    static public var shared: UIViewController? = nil
}

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentingViewController.shared = self
    }
}
