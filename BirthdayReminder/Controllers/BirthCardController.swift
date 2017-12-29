//
//  BirthCardController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 11/11/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CFNotify

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
        nameLabel.text = person.name
        birthLabel.text = "\(person.birth.toLocalizedDate() ?? "")\n(\(person.birth.toLeftDays() ?? ""))"
        imageView.image = UIImage(data: person.picData ?? Data())
        setBackground()
    }
    
    private func setBackground() {
        // Blur Effects
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.frame
        view.addSubview(blurView)
        view.sendSubview(toBack: blurView)
        
        view.backgroundColor = UIColor(gradientStyle: .diagonal, withFrame: view.frame, andColors: [.flatGreen,.flatMint])
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
            NSLocalizedString("%@ is %@'s birthday, let's celebrate!", comment: "%@ is %@'s birthday, let's celebrate!"),
            person.birth.toLocalizedDate()!,person.name) + "\n\(NSLocalizedString("fromBirthReminder", comment: "FromBirthReminder"))"
        let image = imageView.image ?? UIImage()
        let url: URL = "https://captainyukinoshitahachiman.github.io/BirthReminder/"
        
        let controller = UIActivityViewController(activityItems: [text,image,url], applicationActivities: nil)
        
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
            UIPreviewAction(title: "Delete", style: .destructive) { [ctx = context!, person = person!] _,_ in
                    do {
                        ctx.delete(person)
                        try ctx.save()
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
