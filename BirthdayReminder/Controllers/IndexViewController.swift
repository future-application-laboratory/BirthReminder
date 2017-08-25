//
//  IndexViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 20/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class IndexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , NSFetchedResultsControllerDelegate {
    
    weak var delegate: AppDelegate! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate
    }
    weak var context: NSManagedObjectContext! {
        return delegate.context
    }
    var frc: NSFetchedResultsController<NSFetchRequestResult>!
    @IBOutlet weak var tableView: UITableView!
    
    var data = [PeopleToSave]()
    var status = false
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.flatGreen
        navigationController?.navigationBar.barTintColor = UIColor.flatGreenDark
        navigationController?.navigationBar.tintColor = UIColor.flatBlackDark
        emptyLabel.textColor = UIColor.flatWhite
        navigationController?.hidesNavigationBarHairline = true
        setupTableView()
        tableView.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "mainCell")
        let person = self.data[indexPath.row]
        let imageView = cell.imageView
        if let data = person.picData {
            imageView?.image = UIImage(data: data)
        }
        let layer = imageView?.layer
        layer?.masksToBounds = true
        layer?.cornerRadius = 5
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
        cell.textLabel?.textColor = UIColor.flatWhite
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.textColor = UIColor.flatWhite
        cell.textLabel?.text = person.name
        cell.detailTextLabel?.text = status ? person.birth.toLeftDays() : person.birth.toLocalizedDate(withStyle: .long)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        let request = PeopleToSave.sortedFetchRequest
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        data = frc.fetchedObjects as! [PeopleToSave]
        data = BirthComputer.compute(withBirthdayPeople: data)
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
            let row = indexPath.row
            context.delete(data[row])
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            try! context.save()
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
            data = BirthComputer.compute(withBirthdayPeople: data)
            tableView.reloadData()
        case .delete:
            break
        default:
            break // tan90
        }
        checkDataAndDisplayPlaceHolder()
    }
    
    private func checkDataAndDisplayPlaceHolder() {
        if data.isEmpty {
            tableView.separatorStyle = .none
            emptyLabel.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            emptyLabel.isHidden = true
        }
    }
    
    
}
