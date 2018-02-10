//
//  UINavigationController+Extensions.swift
//  BirthdayReminder
//
//  Created by Apollo Zhu on 2/10/18.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

extension UINavigationController {
    /// FIXME: Apple, although I dont' want to, I'm
    /// taking care of the bar tint color for you.
    var barTintColor: UIColor? {
        get {
            return navigationBar.barTintColor
        }
        set {
            // The background color is nil, but still causes a weird
            // difference between the color set and the actual color shown.
            // Therefore, we use an empty image instsead:
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            // This alone should be sufficient, but actually not, for now:
            navigationBar.barTintColor = newValue
            // So we try to set the background color then:
            navigationBar.backgroundColor = newValue
            // We also need to change the status bar color:
            (UIApplication.shared.value(forKey: "statusBar") as! UIView)
                .backgroundColor = newValue
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
