//
//  SquareImageCroppingViewController.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 2018/2/5.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

class SquareImageCroppingViewController: IGRPhotoTweakViewController {

    public var previousController: UIViewController!
    public var misc: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("cropping", comment: "cropping")
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone))
        navigationItem.setRightBarButton(doneBarButtonItem, animated: true)
        navigationItem.hidesBackButton = true
        
        setCropAspectRect(aspect: "1:1")
        lockAspectRatio(true)
        
        self.view.backgroundColor = .background
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func onDone() {
        cropAction()
        navigationController?.popToViewController(previousController, animated: true)
        misc?()
    }
    
}
