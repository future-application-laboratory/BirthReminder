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
import CircleMenu

class IndexViewController: ViewController, ManagedObjectContextUsing {
    
    weak var delegate: AppDelegate! {
        let app = UIApplication.shared
        let delegate = app.delegate as? AppDelegate
        return delegate
    }
    var frc: NSFetchedResultsController<PeopleToSave>!
    @IBOutlet weak var tableView: UITableView!
    let menu: CircleMenu = CircleMenu(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)), normalIcon: "add", selectedIcon: "ic_close", buttonsCount: 2, duration: 0.75, distance: 150)
    
    var data = [PeopleToSave]()
    var status = true
    var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emptyLabelText", comment: "emptyLabelText")
        label.textColor = .white
        label.font = .systemFont(ofSize: 25)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
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
        setupMenu()
        tableView.animate(animations: [AnimationType.zoom(scale: 0.5)])
    }
    
    private func setupMenu() {
        menu.backgroundColor = .flatLime
        menu.delegate = self
        menu.layer.cornerRadius = menu.frame.size.width / 2.0
        menu.addTarget(self, action: #selector(menuTouched(_:)), for: .touchUpInside)
        view.addSubview(menu)
        hideMenu()
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
    
    @objc func menuTouched(_ sender: CircleMenu) {
        if menu.buttonsIsShown() {
            showMenu()
        } else {
            hideMenu()
        }
    }
    
    private func showMenu() {
        UIView.animate(withDuration: 0.1) {
            self.menu.center = self.view.center
        }
    }
    
    private func hideMenu() {
        UIView.animate(withDuration: 0.1) {
            let width = self.view.bounds.width
            let height = self.view.bounds.height
            self.menu.center = CGPoint(x: width - 50, y: height - 150)
        }
    }
    
    @IBAction func changeDateDisplayingType(_ sender: Any) {
        status = !status
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
    
}

extension IndexViewController: CircleMenuDelegate {
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        let image: UIImage?
        let color: UIColor
        switch atIndex {
        case 0:
            image = UIImage(named: "ic_edit")
            color = .flatBlue
        case 1:
            image = UIImage(named: "ic_settings_remote")
            color = .flatWatermelon
        default:
            fatalError()
        }
        button.setImage(image, for: .normal)
        button.backgroundColor = color
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        switch atIndex {
        case 0:
            let controller = PersonFormController()
            controller.setup(with: .new, person: nil)
            controller.title = NSLocalizedString("new", comment: "New")
            controller.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(controller, animated: true)
        case 1:
            performSegue(withIdentifier: "showAnimes", sender: nil)
        default:
            fatalError()
        }
        hideMenu()
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
        cell.birthLabel.text = status ? cellData.birth.toLocalizedDate() : cellData.birth.toLeftDays()
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
        performSegue(withIdentifier: "birthdayCard", sender: data[indexPath.row])
        tableView.reloadRows(at: [indexPath], with: .automatic)
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
