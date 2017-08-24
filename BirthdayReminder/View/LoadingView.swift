//
//  LoadingView.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 24/08/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import LTMorphingLabel

class RoundedSquareCanvas: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let pathRect = bounds.insetBy(dx: 1, dy: 1)
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 10)
        path.lineWidth = 3
        UIColor.darkGray.setFill()
        UIColor.lightGray.setStroke()
        path.fill()
        path.stroke()
    }
    
}

class LoadingView:UIView {
    var text = ""
    let progressView = UIActivityIndicatorView()
    var square:RoundedSquareCanvas?
    let loadingLabel = LTMorphingLabel()
    
    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        square = RoundedSquareCanvas(frame: frame)
        self.addSubview(progressView)
        self.addSubview(square!)
        self.addSubview(loadingLabel)
        self.bringSubview(toFront: square!)
        self.bringSubview(toFront: progressView)
        self.bringSubview(toFront: loadingLabel)
        progressView.color = UIColor.white
        progressView.backgroundColor = UIColor.gray
        progressView.center = self.center
        loadingLabel.morphingEffect = .evaporate
        self.text = text
        loadingLabel.textAlignment = .center
        loadingLabel.textColor = UIColor.white
        loadingLabel.font = UIFont(name: "Pingfang SC", size: 20)
        loadingLabel.snp.makeConstraints { constraint in
            constraint.bottom.equalTo(square!).offset(-10)
            constraint.centerX.equalTo(square!)
            constraint.height.equalTo(50)
        }
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, text: "Loading")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        progressView.startAnimating()
        loadingLabel.isHidden = false
        loadingLabel.text = text
        square?.isHidden = false
    }
    
    func stop() {
        progressView.stopAnimating()
        loadingLabel.isHidden = true
        square?.isHidden = true
    }
    
}
