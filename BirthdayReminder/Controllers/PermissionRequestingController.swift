//
//  PermissionRequestingController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 02/10/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import PAPermissions

class PermissionController: PAPermissionsViewController {
    let photoCheck = PAPhotoLibraryPermissionsCheck()
    let notificationCheck = PANotificationsPermissionsCheck()
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        useBlurBackground = true
        backgroundImage = UIImage(named: "background")
        tintColor = .white
        let permissions = [
            PAPermissionsItem.itemForType(.photoLibrary, reason: NSLocalizedString("photoReason", comment: "phtotReason"))!,
            PAPermissionsItem.itemForType(.notifications, reason: NSLocalizedString("notificationReason", comment: "notificationReason"))!
        ]
        let handlers = [
            PAPermissionsType.photoLibrary.rawValue : photoCheck,
            PAPermissionsType.notifications.rawValue : notificationCheck
        ]
        setupData(permissions, handlers: handlers)
        titleText = NSLocalizedString("permission", comment: "permission")
        detailsText = NSLocalizedString("permissionDetail", comment: "permissionDetail")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentingViewController.shared = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
