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
                //navigationController?.tintColor = .flatBlack()

                tabBarController?.tabBar.backgroundImage = UIImage()
                tabBarController?.tabBar.shadowImage = UIImage()
                tabBarController?.tabBar.isTranslucent = true
            } else {
                tabBarController?.tabBar.shadowImage = nil
                tabBarController?.tabBar.isTranslucent = false
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isTranslucent ? .lightContent : .default
    }
    
    private func setBackground() {
        // Blur Effects
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.sendSubviewToBack(blurView)
        //view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: view.frame, andColors: [.flatGreen(), .flatMint()])
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: CGRect(origin: .zero, size: size), andColors: [.flatGreen(), .flatMint()])
    }

    // MARK: - Functionalities

    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        edit(navigationController: navigationController!)
    }

    @IBAction func onShare(_ sender: UIBarButtonItem) {
        share(on: self)
    }

    func edit(navigationController rootNavigationController: UINavigationController) {
        let controller = PersonFormController(with: .persistent(person))
        controller.title = NSLocalizedString("edit", comment: "edit")
        rootNavigationController.pushViewController(controller, animated: true)
    }

    func share(on rootController: UIViewController, from view: UIView? = nil) {
        let text = String.localizedStringWithFormat(
            NSLocalizedString("%1$@ is %2$@'s birthday, let's celebrate!", comment: "%1$@ is %2$@'s birthday, let's celebrate!"),
            person.birth.toLocalizedDate()!, person.name) + "\n\(NSLocalizedString("fromBirthReminder", comment: "FromBirthReminder"))"
        let image = imageView.image ?? UIImage()

        let controller = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)

        if let popController = controller.popoverPresentationController {
            if rootController === self {
                popController.barButtonItem = navigationItem.rightBarButtonItem
            } else {
                popController.sourceView = view
            }
        }
        rootController.present(controller, animated: true, completion: nil)
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
