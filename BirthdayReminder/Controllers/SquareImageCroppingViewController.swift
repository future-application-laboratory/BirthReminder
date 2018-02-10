//
//  SquareImageCroppingViewController.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 2018/2/5.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import IGRPhotoTweaks

class SquareImageCroppingViewController: IGRPhotoTweakViewController {

    public var previousController: UIViewController!
    public var misc: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("cropping", comment: "cropping")
        
        navigationItem.largeTitleDisplayMode = .never
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone))
        navigationItem.setRightBarButton(doneBarButtonItem, animated: true)
        navigationItem.hidesBackButton = true
        
        setCropAspectRect(aspect: "1:1")
        lockAspectRatio(true)
    }

    @objc private func onDone() {
        cropAction()
        navigationController?.popToViewController(previousController, animated: true)
        misc?()
    }
    
}
