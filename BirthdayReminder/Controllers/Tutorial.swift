//
//  Tutorial.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 02/10/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import Onboard
import PAPermissions
import SnapKit

extension AppDelegate {
    var tutorialController: OnboardViewController? {
        let backgroundImage = UIImage(named: "background")
        
        let page1 = OnboardingContentViewController(title: NSLocalizedString("page1title", comment: "page1 title"), body: NSLocalizedString("page1body", comment: "page1 body"), image: nil, buttonText: nil, action: nil)
        let page2 = OnboardingContentViewController(title: NSLocalizedString("page2title", comment: "page2 title"), body: NSLocalizedString("page2body", comment: "page2 body"), image: nil, buttonText: nil, action: nil)
        let page3 = OnboardingContentViewController(title: NSLocalizedString("page3title", comment: "page3 title"), body: NSLocalizedString("page3body", comment: "page3 body"), image: nil, buttonText: nil, action: nil)
        let page4 = OnboardingContentViewController(title: NSLocalizedString("page4title", comment: "page4 title"), body: NSLocalizedString("page4body", comment: "page4 body"), image: nil, buttonText: NSLocalizedString("setup", comment: "setup"), action: nil)
        let contentVCs = [page1,page2,page3,page4]
        
        let onboardVC = OnboardViewController(backgroundImage: backgroundImage, contents: contentVCs)
        onboardVC?.allowSkipping = true
        onboardVC?.skipHandler = {
            let defaults = UserDefaults()
            defaults.set(true, forKey: "beenLaunched")
            onboardVC?.show(UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!, sender: nil)
            UIApplication.shared.statusBarStyle = .default
        }
        
        contentVCs.last?.viewDidAppearBlock = {
            onboardVC?.skipButton.setTitle(NSLocalizedString("enjoy", comment: "enjoy"), for: .normal)
        }
        for times in 0..<(contentVCs.count - 1) {
            contentVCs[times].viewDidAppearBlock = {
                onboardVC?.skipButton.setTitle(NSLocalizedString("skip", comment: "skip"), for: .normal)
            }
        }
        page4.actionButton.addTarget(nil, action: #selector(onboardVC?.requestPermisson), for: .touchUpInside)
        page4.bottomPadding = 10
        
        onboardVC?.viewControllers.forEach { controller in
            if let onbordContentController = controller as? OnboardingContentViewController {
                if UIScreen.main.bounds.height < 665 {
                    onbordContentController.titleLabel.font = UIFont.systemFont(ofSize: 40)
                    onbordContentController.bodyLabel.font = UIFont.systemFont(ofSize: 20)
                }
            }
        }
        
        return onboardVC
    }
}

class OnboardViewController: OnboardingViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIScreen.main.bounds.height == 812 {
            pageControl.snp.makeConstraints() { make in
                make.bottom.equalToSuperview().inset(20)
                make.centerX.equalToSuperview()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func requestPermisson() {
        show(PermissionController(), sender: nil)
    }
}
