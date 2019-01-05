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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isTranslucent = false
    }

    // MARK: - Styling

    private var isTranslucent: Bool = false {
        didSet {
            if oldValue == isTranslucent { return }
            if isTranslucent {
                navigationController?.setVisualEffectViewHidden()
                navigationController?.tintColor = .flatBlack

                tabBarController?.tabBar.backgroundImage = UIImage()
                tabBarController?.tabBar.shadowImage = UIImage()
                tabBarController?.tabBar.isTranslucent = true

                UIApplication.shared.statusBarStyle = .default
            } else {
                navigationController?.setVisualEffectViewHidden(false)
                navigationController?.tintColor = .tint

                tabBarController?.tabBar.barTintColor = .bar
                tabBarController?.tabBar.shadowImage = nil
                tabBarController?.tabBar.isTranslucent = false

                UIApplication.shared.statusBarStyle = .lightContent
            }
        }
    }

    private func setBackground() {
        // Blur Effects
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.sendSubview(toBack: blurView)
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: view.frame, andColors: [.flatGreen, .flatMint])
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(origin: .zero, size: size), andColors: [.flatGreen, .flatMint])
    }

    // MARK: - Functionalities

    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        edit(navigationController: navigationController!)
    }

    @IBAction func onShare(_ sender: UIBarButtonItem) {
        share(controller: self)
    }

    func edit(navigationController rootNavigationController: UINavigationController) {
        let controller = PersonFormController(with: .persistent(person))
        controller.title = NSLocalizedString("edit", comment: "edit")
        rootNavigationController.pushViewController(controller, animated: true)
    }

    func share(controller rootController: UIViewController) {
        let text = String.localizedStringWithFormat(
            NSLocalizedString("%1$@ is %2$@'s birthday, let's celebrate!", comment: "%1$@ is %2$@'s birthday, let's celebrate!"),
            person.birth.toLocalizedDate()!, person.name) + "\n\(NSLocalizedString("fromBirthReminder", comment: "FromBirthReminder"))"
        let image = imageView.image ?? UIImage()

        let controller = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)

        if let popController = controller.popoverPresentationController {
            popController.barButtonItem = navigationItem.rightBarButtonItem
        }
        rootController.present(controller, animated: true, completion: nil)
    }

    override var previewActionItems: [UIPreviewActionItem] {
        let tabbarController: UITabBarController
        //  swiftlint:disable force_cast
        if let onboardController = UIApplication.shared.keyWindow?.rootViewController as? OnboardViewController {
            tabbarController = onboardController.presentedViewController as! UITabBarController
        } else {
            tabbarController = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
        }
        let indexController = tabbarController.viewControllers![0] as! UINavigationController
        //  swiftlint:enable force_cast
        return [
            UIPreviewAction(title: NSLocalizedString("share", comment: "share"), style: .default) { [unowned self] _, _ in
                self.share(controller: indexController)
            },
            UIPreviewAction(title: NSLocalizedString("edit", comment: "edit"), style: .default) { [unowned self] _, _ in
                self.edit(navigationController: indexController)
            },
            UIPreviewAction(title: NSLocalizedString("delete", comment: "delete"), style: .destructive) { [context = context!, person = person!] _, _ in
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

}

extension BirthCardController {

    static func show(for person: PeopleToSave) {
        if let cardViewController = UIStoryboard.main
            .instantiateViewController(withIdentifier: "birthCard") as? BirthCardController {
            cardViewController.person = person
            let presented = PresentingViewController.shared
            presented?.navigationController?.pushViewController(cardViewController, animated: true)
        }
    }

}
