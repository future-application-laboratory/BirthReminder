//
//  PersonFormController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 16/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import CoreData
import StoreKit
import CFNotify
import IGRPhotoTweaks

class PersonFormController: FormViewController, ManagedObjectContextUsing, IGRPhotoTweakViewControllerDelegate {
    
    private let formMode: Mode
    
    enum Mode {
        case new(People?)
        case persistent(PeopleToSave)
    }
    
    private lazy var newPerson: People? = {
        switch formMode {
        case .new(let person):
            return person
        default:
            return nil
        }
    }()
    private lazy var persistentPerson: PeopleToSave? = {
        switch formMode {
        case .persistent(let person):
            return person
        default:
            return nil
        }
    }()
    
    private var imageRow: ImageRow!
    private var nameRow: TextRow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Form Defination
        form +++ Section(NSLocalizedString("name", comment: "name"))
            <<< TextRow() { row in
                row.tag = "name"
                row.title = NSLocalizedString("name", comment: "name")
                row.placeholder = NSLocalizedString("name", comment: "name")
                row.value = newPerson?.name ?? persistentPerson?.name
                self.nameRow = row
            }
            +++ Section(NSLocalizedString("birth", comment: "Birth"))
            <<< DatePickingRow() { row in
                row.tag = "birth"
                row.title = NSLocalizedString("birth", comment: "Birth")
                row.value = (newPerson?.stringedBirth ?? persistentPerson?.birth) ?? "01-01"
            }
            +++ Section(NSLocalizedString("image", comment: "Image"))
            <<< ImageRow() { row in
                row.tag = "image"
                row.title = NSLocalizedString("image", comment: "Image")
                row.value = UIImage(data: (newPerson?.picPack?.data ?? persistentPerson?.picData) ?? Data())
                row.didSetImage = didSet
                row.sourceTypes = ImageRowSourceTypes.PhotoLibrary
                self.imageRow = row
            }
            <<< TextRow() { row in
                row.tag = "imageCopyright"
                row.title = NSLocalizedString("copyrightInfo", comment: "copyrightInfo")
                row.placeholder = NSLocalizedString("optional", comment: "optional")
                row.value = persistentPerson?.picCopyright
            }
            +++ Section(NSLocalizedString("appleWatchSyncing", comment: "AppleWatchSyncing"))
            <<< SwitchRow() { row in
                row.tag = "shouldSync"
                row.title = NSLocalizedString("syncWithAW", comment: "syncWithAW")
                row.value = persistentPerson?.shouldSync ?? false
        }
        switch formMode {
        case .persistent(let persistentPerson):
            form +++ Section()
                <<< DeleteButtonRow() { row in
                    row.context = context
                    row.objectToDelete = persistentPerson
                    row.confirmationParentViewControlelr = self
                    row.title = NSLocalizedString("delete", comment: "Delete")
            }
        default:
            break
        }
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSave(sender:)))
        navigationItem.setRightBarButton(barButtonItem, animated: true)
        
        // Drag&Drop Integration
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentingViewController.shared = self
    }
    
    @objc private func onSave(sender: UIBarButtonItem) {
        let values = form.values()
        let name = values["name"] as? String
        let birth = values["birth"] as? String
        let image = values["image"] as? UIImage
        let imageData = UIImagePNGRepresentation(image ?? UIImage())
        let imageCopyright = values["imageCopyright"] as? String
        let shouldSync = values["shouldSync"] as? Bool
        
        switch formMode {
        case .new:
            PeopleToSave.insert(into: context, name: name ?? "", birth: birth ?? "01-01", picData: imageData, picCopyright: imageCopyright, shouldSync: shouldSync ?? false)
        case .persistent:
            do {
                persistentPerson?.name = name ?? ""
                persistentPerson?.birth = birth ?? "01-01"
                persistentPerson?.picData = imageData
                persistentPerson?.picCopyright = imageCopyright
                persistentPerson?.shouldSync = shouldSync ?? false
                try context.save()
            } catch {
                let cfView = CFNotifyView.cyberWith(title: NSLocalizedString("failedToSave", comment: "FailedToSave"), body: error.localizedDescription, theme: .fail(.light))
                var config = CFNotify.Config()
                config.initPosition = .top(.center)
                config.appearPosition = .top
                CFNotify.present(config: config, view: cfView)
            }
        }
        
        navigationController?.popViewController(animated: true)
        SKStoreReviewController.requestReview()
    }
    
    private func delete() {
        let alertController = UIAlertController(title: NSLocalizedString("deletionConfirm", comment: ""), message: NSLocalizedString("deletionConfirmDetailed", comment: ""), preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default) { [unowned self] _ in
            do {
                self.context.delete(self.persistentPerson!)
                try self.context.save()
                self.navigationController?.popToRootViewController(animated: true)
            } catch {
                let cfView = CFNotifyView.cyberWith(title: NSLocalizedString("failedToSave", comment: "FailedToSave"), body: error.localizedDescription, theme: .fail(.light))
                var config = CFNotify.Config()
                config.initPosition = .top(.center)
                config.appearPosition = .top
                CFNotify.present(config: config, view: cfView)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        imageRow.value = croppedImage
        imageRow.cell.update()
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        
    }
    
    private func didSet(image: UIImage?) {
        if let image = image {
            let controller = SquareImageCroppingViewController()
            controller.image = image
            controller.delegate = self
            controller.previousController = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    init(with mode: Mode) {
        formMode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PersonFormController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { images in
            if let image = images.first {
                self.didSet(image: image as? UIImage)
            }
        }
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            if let urls = nsurls as? [URL],
                let url = urls.first,
                let _ = self.nameRow.value {
                self.nameRow.value! += url.path
            }
        }
    }
    
}

final class DeleteButtonRow: _ButtonRowOf<String>, RowType {
    
    weak var objectToDelete: NSManagedObject!
    weak var context: NSManagedObjectContext!
    weak var confirmationParentViewControlelr: UIViewController!
    
    override func customDidSelect() {
        let alertController = UIAlertController(title: NSLocalizedString("deletionConfirm", comment: ""), message: NSLocalizedString("deletionConfirmDetailed", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default) { _ in
            self.context?.delete(self.objectToDelete)
            try? self.context?.save()
            self.confirmationParentViewControlelr.navigationController?.popToRootViewController(animated: true)
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel))
        confirmationParentViewControlelr.present(alertController, animated: true, completion: nil)
    }
    
    required init(tag: String?) {
        super.init(tag: tag)
        cell.tintColor = #colorLiteral(red: 0.8881979585, green: 0.3072378635, blue: 0.2069461644, alpha: 1)
    }
    
}
