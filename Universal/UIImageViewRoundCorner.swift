//
//  UIImageViewRoundCorner.swift
//  BirthdayReminder
//
//  Created by CaptainYukinoshitaHachiman on 2019/6/24.
//  Copyright © 2019 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

class UIImageViewRoundCorner: UIImageView {

    public var corners: UIRectCorner = .bottomRight {
        didSet {
            layoutSubviews()
        }
    }
    
    public var radius: CGFloat = 3.0 {
        didSet {
            layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: corners, radius: radius)
    }
    
}

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
}
