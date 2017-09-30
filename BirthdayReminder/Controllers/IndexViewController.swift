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
import SideMenu

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
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        navigationController?.navigationBar.barTintColor = UIColor.bar
        navigationController?.navigationBar.tintColor = UIColor.tint
        emptyLabel.textColor = UIColor.label
        navigationController?.hidesNavigationBarHairline = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.title]
        setupTableView()
        setupSideMenu()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.section
        let cellData = data[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell", for: indexPath) as! PersonalCell
        cell.nameLabel.text = cellData.name
        cell.birthLabel.text = status ? cellData.birth.toLocalizedDate(withStyle: .long) : cellData.birth.toLeftDays()
        if let imgData = cellData.picData {
            cell.picView.image = UIImage(data: imgData)
        } else {
            cell.picView.image = UIImage(image: UIImage(), scaledTo: CGSize(width: 100, height: 100))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = UIScreen.main.bounds.width - 20
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
        view.backgroundColor = UIColor.background
        return view
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.section
            context.delete(data[index])
            try? context.save()
            data.remove(at: index)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @IBAction func changeDateDisplayingType(_ sender: Any) {
        status = !status
        tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let person = anObject as! PeopleToSave
            data.append(person)
            data.sort()
            tableView.reloadData()
        case .delete:
            delegate.syncWithAppleWatch()
        default:
            break // tan90
        }
        checkDataAndDisplayPlaceHolder()
    }
    
    private func checkDataAndDisplayPlaceHolder() {
        if data.isEmpty {
            tableView.separatorStyle = .none
            emptyLabel.textColor = .label2
            emptyLabel.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            emptyLabel.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let sectionHeaderHeight: CGFloat = 20
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
        } else if scrollView.contentOffset.y >= sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsetsMake(CGFloat(-sectionHeaderHeight), 0, 0, 0)
        }
    }
    
    private func setupSideMenu() {
        let leftMenu = storyboard!.instantiateViewController(withIdentifier: "leftMenuNavigationController") as? SideMenuNavigationController
        leftMenu?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.title]
        SideMenuManager.menuLeftNavigationController = leftMenu
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.menuAnimationBackgroundColor = .bar
    }
    
}
