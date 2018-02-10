//
//  BirthCardController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 11/11/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CFNotify
import SnapKit

class BirthCardController: ViewController, ManagedObjectContextUsing {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    
    public var person: PeopleToSave!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameLabel.text = person.name
        birthLabel.text = "\(person.birth.toLocalizedDate() ?? "")\n(\(person.birth.toLeftDays() ?? ""))"
        imageView.image = UIImage(data: person.picData ?? Data())
        isTranslucent = true
    }

    private var isTranslucent: Bool = false {
        didSet {
            if isTranslucent {
                navigationController?.barTintColor = .clear
                navigationController?.tintColor = .flatBlack

                tabBarController?.tabBar.backgroundImage = UIImage()
                tabBarController?.tabBar.shadowImage = UIImage()
                tabBarController?.tabBar.isTranslucent = true
            } else {
                navigationController?.barTintColor = .bar
                navigationController?.tintColor = .tint

                tabBarController?.tabBar.barTintColor = .bar
                tabBarController?.tabBar.shadowImage = nil
                tabBarController?.tabBar.isTranslucent = false
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isTranslucent = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isTranslucent = false
    }
    
    private func setBackground() {
        // Blur Effects
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurView)
        blurView.snp.makeConstraints() { make in
            make.edges.equalToSuperview()
        }
        view.sendSubview(toBack: blurView)
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: view.frame, andColors: [.flatGreen,.flatMint])
    }
    
    
    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        edit(navigationController: navigationController!)
    }
    
    @IBAction func onShare(_ sender: UIBarButtonItem) {
        share(controller: self)
    }
    
    func edit(navigationController rootNavigationController: UINavigationController) {
        let controller = PersonFormController()
        controller.setup(with: .edit, person: person)
        controller.title = NSLocalizedString("edit", comment: "edit")
        rootNavigationController.pushViewController(controller, animated: true)
    }
    
    func share(controller rootController: UIViewController) {
        let text = String.localizedStringWithFormat(
            NSLocalizedString("%1$@ is %2$@'s birthday, let's celebrate!", comment: "%1$@ is %2$@'s birthday, let's celebrate!"),
            person.birth.toLocalizedDate()!,person.name) + "\n\(NSLocalizedString("fromBirthReminder", comment: "FromBirthReminder"))"
        // let image = imageView.image ?? UIImage()
        
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let popController = controller.popoverPresentationController {
            popController.barButtonItem = navigationItem.rightBarButtonItem
        }
        rootController.present(controller, animated: true, completion: nil)
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        let tabbarController = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
        let _navigationController = tabbarController.viewControllers![1] as! UINavigationController
        let indexController = _navigationController
        return [
            UIPreviewAction(title: "Share", style: .default) { [unowned self] _,_ in
                self.share(controller: indexController)
            },
            UIPreviewAction(title: "Edit", style: .default) { [unowned self] _,_ in
                self.edit(navigationController: _navigationController)
            },
            UIPreviewAction(title: "Delete", style: .destructive) { [context = context!, person = person!] _,_ in
                do {
                    context.delete(person)
                    try context.save()
                } catch {
                    let cfView = CFNotifyView.cyberWith(title: NSLocalizedString("failedToSave", comment: "FailedToSave"), body: error.localizedDescription, theme: .fail(.light))
                    var config = CFNotify.Config()
                    config.initPosition = .top(.center)
                    config.appearPosition = .top
                    CFNotify.present(config: config, view: cfView)
                }
            }
        ]
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(origin: .zero, size: size), andColors: [.flatGreen,.flatMint])
    }
}
