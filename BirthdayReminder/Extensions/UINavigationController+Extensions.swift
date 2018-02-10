//
//  UINavigationController+Extensions.swift
//  BirthdayReminder
//
//  Created by Apollo Zhu on 2/10/18.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

extension UINavigationController {
    var barTintColor: UIColor? {
        get {
            return navigationBar.barTintColor
        }
        set {
            navigationBar.barTintColor = newValue
        }
    }
    
    func setVisualEffectViewHidden(_ isHidden: Bool = true) {
        navigationBar.subviews.forEach {
            $0.subviews.forEach {
                if let background = $0 as? UIVisualEffectView {
                    background.isHidden = isHidden
                }
            }
        }
    }
    
    /// Tint/text color for bar and title.
    var tintColor: UIColor {
        get {
            return navigationBar.tintColor
        }
        set {
            navigationBar.tintColor = newValue
            navigationBar.titleTextAttributes![.foregroundColor] = newValue
            navigationBar.largeTitleTextAttributes![.foregroundColor] = newValue
        }
    }
}
