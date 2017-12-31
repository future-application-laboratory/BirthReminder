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
    private var isContributing = false
    
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
        tableView.animate(animations: [AnimationType.zoom(scale: 0.5)])
        setupContributingButton()
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
    
    private func setupContributingButton() {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(onContribute(_:)))
        navigationItem.leftBarButtonItem = buttonItem
    }
    
    @objc private func onContribute(_ sender: UIBarButtonItem) {
        isContributing = !isContributing
        floaty.isHidden = isContributing
        tableView.allowsMultipleSelection = isContributing
        let barButtonSystemItem = isContributing ? UIBarButtonSystemItem.done : .action
        let buttonItem = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target: self, action: #selector(onContribute(_:)))
        navigationItem.leftBarButtonItem = buttonItem
        if isContributing {
            showContributeInstructionsIfNeeded()
        } else {
            let alertController = UIAlertController(title: "End editing", message: "Are you sure to contribute these selected characters?", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Done", style: .default) { action in
                self.showFurtherContributeOptions()
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in })
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func showContributeInstructionsIfNeeded() {
        fatalError("not implemented")
    }
    
    private func showFurtherContributeOptions() {
        fatalError("not implemented")
    }
    
}

extension IndexViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let person = anObject as? PeopleToSave else { return }
        switch type {
        case .insert:
            let person = anObject as! PeopleToSave
            data.append(person)
            data.sort()
            tableView.reloadData()
            NotificationManager.onInsert(person: person)
        case .delete:
            data = frc.fetchedObjects!
            data.sort()
            tableView.reloadData()
            NotificationManager.onRemove(person: person)
        case .update:
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.allowsMultipleSelection {
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
