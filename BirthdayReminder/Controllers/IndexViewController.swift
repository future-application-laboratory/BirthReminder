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

class IndexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    weak var delegate: AppDelegate! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate
    }
    weak var context: NSManagedObjectContext! {
        return delegate.context
    }
    var frc: NSFetchedResultsController<PeopleToSave>!
    @IBOutlet weak var tableView: UITableView!
    
    var data = [PeopleToSave]()
    var status = true
    var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emptyLabelText", comment: "emptyLabelText")
        label.textColor = .white
        label.font = .systemFont(ofSize: 25)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        navigationController?.navigationBar.barTintColor = UIColor.bar
        navigationController?.navigationBar.tintColor = UIColor.tint
        emptyLabel.textColor = UIColor.label
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints() { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.height.lessThanOrEqualToSuperview()
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.bringSubview(toFront: tableView)
        navigationController?.hidesNavigationBarHairline = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.title]
        setupTableView()
        tableView.animate(animations: [AnimationType.zoom(scale: 0.5)])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data .count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cellData = data[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell", for: indexPath) as! PersonalCell
        cell.nameLabel.text = cellData.name
        cell.birthLabel.text = status ? cellData.birth.toLocalizedDate() : cellData.birth.toLeftDays()
        if let imgData = cellData.picData {
            cell.picView.image = UIImage(data: imgData)
        } else {
            cell.picView.image = UIImage(image: UIImage(), scaledTo: CGSize(width: 100, height: 100))
        }
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: cell)
        }
        
        return cell
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        let request = PeopleToSave.sortedFetchRequest
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        data = frc.fetchedObjects!
        data = BirthComputer.peopleOrderedByBirthday(peopleToReorder: data)
        checkDataAndDisplayPlaceHolder()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "birthdayCard", sender: data[indexPath.row])
        tableView.reloadRows(at: [indexPath], with: .automatic)
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
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("new", comment: "new"), style: .default) { [unowned self] action in
            let controller = PersonFormController()
            controller.setup(with: .new, person: nil)
            controller.title = NSLocalizedString("new", comment: "New")
            controller.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(controller, animated: true)
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("import", comment: "import"), style: .default) { [unowned self] action in
            self.performSegue(withIdentifier: "showAnimes", sender: nil)
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel))
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeDateDisplayingType(_ sender: Any) {
        status = !status
        tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        NotificationManager.reloadNotifications()
        switch type {
        case .insert:
            let person = anObject as! PeopleToSave
            data.append(person)
            data.sort()
            tableView.reloadData()
        case .delete:
            data = frc.fetchedObjects!
            data.sort()
            tableView.reloadData()
            delegate.syncWithAppleWatch()
        default:
            break // tan90
        }
        checkDataAndDisplayPlaceHolder()
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
