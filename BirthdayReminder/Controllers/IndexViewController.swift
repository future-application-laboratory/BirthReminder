//
//  IndexViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 20/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CoreData
import SnapKit
import ViewAnimator
import Floaty
import MobileCoreServices
import IGRPhotoTweaks
import NVActivityIndicatorView

class IndexViewController: ViewController, ManagedObjectContextUsing {
    
    weak var delegate: AppDelegate! {
        let app = UIApplication.shared
        let delegate = app.delegate as? AppDelegate
        return delegate
    }
    var frc: NSFetchedResultsController<PeopleToSave>!
    @IBOutlet weak var tableView: UITableView!
    
    private var data = [PeopleToSave]()
    private var timeShouldShowAsLocalizedDate = true
    
    private var isContributing = false {
        didSet {
            floaty.isHidden = isContributing
            tableView.allowsMultipleSelection = isContributing
            if isContributing {
                onContribute()
            } else {
                navigationItem.setLeftBarButtonItems([], animated: true)
            }
        }
    }
    private var animePic: UIImage!
    private var picCopyright: String!
    private var animeName: String!
    private var contactInfo: String!
    
    private var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emptyLabelText", comment: "emptyLabelText")
        label.textColor = .white
        label.font = .systemFont(ofSize: 25)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 150)), type: .orbit, color: .cell, padding: nil)
    private let indicatorBackground = UIView()
    
    private let floaty = Floaty()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints() { make in
            make.center.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        emptyLabel.bringSubview(toFront: tableView)
        navigationController?.hidesNavigationBarHairline = true
        navigationController?.navigationBar.barTintColor = .bar
        navigationController?.navigationBar.tintColor = .tint
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.title]
        setupTableView()
        setupFloaty()
        setupIndicator()
        tableView.animate(animations: [AnimationType.zoom(scale: 0.5)])
    }
    
    private func setupFloaty() {
        floaty.sticky = true
        floaty.friendlyTap = true
        floaty.hasShadow = false
        floaty.buttonImage = UIImage(named: "add")
        floaty.overlayColor = .clear
        floaty.buttonColor = .flatMintDark
        floaty.addItem(NSLocalizedString("new", comment: "New"), icon: UIImage(named: "ic_edit")) { item in
            let controller = PersonFormController()
            controller.setup(with: .new, person: nil)
            controller.title = NSLocalizedString("new", comment: "New")
            controller.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(controller, animated: true)
        }
        floaty.addItem(NSLocalizedString("remote", comment: "remote"), icon: UIImage(named: "ic_remote")) { item in
            self.performSegue(withIdentifier: "showAnimes", sender: nil)
        }
        floaty.items.forEach() { item in
            item.buttonColor = .flatMint
        }
        tableView.addSubview(floaty)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        let request = PeopleToSave.sortedFetchRequest
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        data = frc.fetchedObjects!
        data = BirthComputer.peopleOrderedByBirthday(peopleToReorder: data)
        checkDataAndDisplayPlaceHolder()
    }
    
    private func setupIndicator() {
        indicatorBackground.backgroundColor = .gray
        indicatorBackground.alpha = 0.5
        indicatorBackground.isHidden = true
        view.addSubview(indicatorBackground)
        indicatorBackground.snp.makeConstraints() { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints() { make in
            make.center.equalToSuperview()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "birthdayCard":
                if let person = sender as? PeopleToSave {
                    (segue.destination as? BirthCardController)?.person = person
                }
            default:
                break
            }
        }
    }
    
    @IBAction func changeDateDisplayingType(_ sender: Any) {
        timeShouldShowAsLocalizedDate = !timeShouldShowAsLocalizedDate
        tableView.reloadData()
    }
    
    private func checkDataAndDisplayPlaceHolder() {
        tableView.separatorStyle = .none
        if data.isEmpty {
            emptyLabel.textColor = .label2
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
        }
    }
    
}

extension IndexViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let person = anObject as? PeopleToSave else { return }
        let index = data.index(of: person)
        switch type {
        case .insert:
            data.append(person)
            data.sort()
            tableView.reloadData()
            NotificationManager.onInsert(person: person)
        case .delete:
            data.remove(at: index!)
            tableView.deleteRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
            NotificationManager.onRemove(person: person)
        case .update:
            tableView.reloadRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
            NotificationManager.onModify(person: person)
        default:
            break
        }
        checkDataAndDisplayPlaceHolder()
        delegate.syncWithAppleWatch()
    }
    
}

extension IndexViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cellData = data[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell", for: indexPath) as! PersonalCell
        cell.nameLabel.text = cellData.name
        cell.birthLabel.text = timeShouldShowAsLocalizedDate ? cellData.birth.toLocalizedDate() : cellData.birth.toLeftDays()
        DispatchQueue.global(qos: .userInteractive).async {
            let picImage: UIImage?
            if let imgData = cellData.picData {
                picImage = UIImage(data: imgData)
            } else {
                picImage = UIImage().imageScaled(to: CGSize(width: 100, height: 100))
            }
            DispatchQueue.main.async {
                cell.picView.image = picImage
            }
        }
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: cell)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.allowsMultipleSelection {
            let index = indexPath.row
            let person = data[index]
            let readyForContribution = person.picCopyright != nil && person.picCopyright != ""
            if !readyForContribution {
                tableView.reloadRows(at: [indexPath], with: .automatic)
                illegalContributionAlert()
            }
        } else {
            performSegue(withIdentifier: "birthdayCard", sender: data[indexPath.row])
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
}

extension IndexViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let cell = previewingContext.sourceView as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)!
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            if let controller = storyBoard.instantiateViewController(withIdentifier: "birthCard") as? BirthCardController{
                let person = data[indexPath.row]
                controller.person = person
                return controller
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        viewControllerToCommit.hidesBottomBarWhenPushed = true
        show(viewControllerToCommit, sender: nil)
    }
    
}

// Contributing
extension IndexViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, IGRPhotoTweakViewControllerDelegate {
    
    public func startContributingIfNotAlready() {
        if isContributing != true {
            isContributing = true
        }
    }
    
    private func onContribute() {
        showContributeInstructions()
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.setLeftBarButtonItems([buttonItem], animated: true)
    }
    
    private func showContributeInstructions() {
        let alertController = UIAlertController(title: "You're entering contributing mode", message: "For more details, checkout URL", preferredStyle: .alert) // todo
        alertController.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "No, that's not what I want", style: .default) { _ in
            self.isContributing = false
        })
        present(alertController, animated: true)
    }
    
    private func illegalContributionAlert() {
        let alertController = UIAlertController(title: "No pic copyright provided", message: "Pic copyright is required to contribute, please edit the character before contributing", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func done() {
        let alertController = UIAlertController(title: "End editing", message: "Are you sure to contribute these selected characters?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Yes, I'd like to contribute the selected \(tableView.indexPathsForSelectedRows?.count ?? 0) character(s)", style: .default) { _ in
            self.getAnimeName()
        })
        alertController.addAction(UIAlertAction(title: "No, I'd like to make a few more changes", style: .cancel))
        alertController.addAction(UIAlertAction(title: "No, I'd like to exit contributing mode", style: .destructive) { _ in
            self.isContributing = false
        })
        present(alertController, animated: true, completion: nil)
    }
    
    private func getAnimeName() {
        let alertController = UIAlertController(title: "What's the name of the character set?", message: "e.g. Anime names, Galgame names, Lightnovel names...", preferredStyle: .alert)
        alertController.addTextField() { field in
            field.placeholder = "The name of the set of characters"
        }
        alertController.addAction(UIAlertAction(title: "Next", style: .default) { _ in
            self.animeName = alertController.textFields!.first!.text!
            self.askForAnimePic()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in self.isContributing = false })
        present(alertController, animated: true)
    }
    
    private func askForAnimePic() {
        let alertController = UIAlertController(title: "Choose the pic for the set", message: "Its copyright info is also required", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Choose from album", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            let picker = UIImagePickerController()
            picker.allowsEditing = false
            picker.delegate = self
            picker.mediaTypes =  [kUTTypeImage as String]
            picker.sourceType = .savedPhotosAlbum
            self.present(picker, animated: true, completion: nil)
        })
        present(alertController, animated: true)
    }
    
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        animePic = croppedImage
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        animePic = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true) {
            // cropping
            let controller = SquareImageCroppingViewController()
            controller.image = self.animePic
            controller.delegate = self
            controller.previousController = self
            controller.misc = {
                self.askForCopyrightInfo()
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        isContributing = false
    }
    
    private func askForCopyrightInfo() {
        let alertController = UIAlertController(title: "Copyright Info", message: "Enter the copyright info for the pic you've just selected", preferredStyle: .alert)
        alertController.addTextField() { field in
            field.placeholder = "Copyright Info"
        }
        alertController.addAction(UIAlertAction(title: "Next", style: .default) { _ in
            self.picCopyright = alertController.textFields?.first?.text
            self.askForContactInfo()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    private func askForContactInfo() {
        let alertController = UIAlertController(title: "Almost done", message: "Finally, leave your contact info here.\n It's not forced, but we can then express our strong thankfulness through the info if you do so.", preferredStyle: .alert)
        alertController.addTextField() { field in
            field.placeholder = "Nickname and contact info (optional)"
        }
        alertController.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            self.contactInfo = alertController.textFields?.first?.text
            self.submit()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    private func submit() {
        let animePicPack = PicPack(image: animePic, copyrightInfo: picCopyright)!
        let people: [People] = (tableView.indexPathsForSelectedRows ?? []).map() { indexPath in
            let index = indexPath.row
            let person =  data[index]
            let name = person.name
            let birth = person.birth
            let picData = person.picData!
            let copyright = person.picCopyright!
            let personForContribution = People(withName: name, birth: birth, picData: picData, id: nil)
            personForContribution.picPack?.copyright = copyright
            return personForContribution
        }
        activityIndicator.startAnimating()
        indicatorBackground.isHidden = false
        NetworkController.networkQueue.async {
            NetworkController.provider.request(TCWQService.contribution(animeName: self.animeName, animePicPack: animePicPack, people: people, contributorInfo: self.contactInfo)) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.indicatorBackground.isHidden = true
                    switch result {
                    case .success(let response):
                        if response.statusCode == 200 {
                            self.isContributing = false
                            let controller = UIAlertController(title: NSLocalizedString("done", comment: "Done"), message: NSLocalizedString("contributionThanks", comment: "contributionThanks"), preferredStyle: .alert)
                            controller.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .default))
                            self.present(controller, animated: true, completion: nil)
                        } else {
                            let controller = UIAlertController(title: NSLocalizedString("failedToUpload", comment: "Failed To Upload"), message: response.description, preferredStyle: .alert)
                            controller.addAction(UIAlertAction(title: NSLocalizedString("retry", comment: "Retry"), style: .default) { _ in
                                self.submit()
                            })
                            controller.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .default) { _ in
                                self.isContributing = false
                            })
                            self.present(controller, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        let controller = UIAlertController(title: NSLocalizedString("failedToUpload", comment: "Failed To Upload"), message: error.localizedDescription, preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: NSLocalizedString("retry", comment: "Retry"), style: .default) { _ in
                            self.submit()
                        })
                        controller.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .default) { _ in
                            self.isContributing = false
                        })
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}
