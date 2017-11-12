//
//  BirthCardController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 11/11/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

class BirthCardController: UIViewController {
    
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
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        let controller = PersonFormController()
        controller.setup(with: .edit, person: person)
        controller.title = NSLocalizedString("edit", comment: "edit")
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let text = String.localizedStringWithFormat(
            NSLocalizedString("%@'s birthday is coming, let's celebrate on %@!", comment: ""),
            person.name,person.birth.toLocalizedDate()!)
        let image = imageView.image ?? UIImage()
        let url = URL(string: "https://www.tcwq.tech/")!
        
        let controller = UIActivityViewController(activityItems: [text,image,url], applicationActivities: nil)
        
        if let popController = controller.popoverPresentationController {
            popController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(controller, animated: true, completion: nil)
    }
    
}
