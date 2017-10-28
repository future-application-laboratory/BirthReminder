//
//  ImageProcessing.swift
//  BirthdayReminder
//
//  Created by Jack Lee on 28/10/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

extension UIImage {
	
	func cornerImage(size:CGSize, radius:CGFloat, fillColor: UIColor, completion:@escaping ((_ image: UIImage)->())) -> Void {
		DispatchQueue.global().async {
			UIGraphicsBeginImageContextWithOptions(size, true, 0)
			let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
			fillColor.setFill()
			UIRectFill(rect)
			let path = UIBezierPath.init(roundedRect: rect, cornerRadius: radius)
			path.addClip()
			self.draw(in: rect)
			let resultImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			DispatchQueue.main.async {
				completion(resultImage!)
			}
		}
	}
}
