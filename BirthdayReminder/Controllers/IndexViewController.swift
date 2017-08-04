//
//  IndexViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 20/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CoreData

class IndexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , NSFetchedResultsControllerDelegate {
    
    weak var context: NSManagedObjectContext! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate.context
    }
    var frc: NSFetchedResultsController<NSFetchRequestResult>!
    @IBOutlet weak var tableView: UITableView!
    
    var data = [PeopleToSave]()
    var status = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        imageView?.image = UIImage(data: person.picData)
        let layer = imageView?.layer
        layer?.masksToBounds = true
        layer?.cornerRadius = 5
        cell.textLabel?.font = UIFont(name: "PingFangTC-Light", size: 18)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.font = UIFont(name: "PingFangSC-Semibold",size: 16)
        cell.detailTextLabel?.numberOfLines = 2
        cell.detailTextLabel?.textColor = UIColor.white
        cell.textLabel?.text = person.name
        cell.detailTextLabel?.text = status ? person.birth.toLeftDays() : person.birth.toLocalizedDate(withStyle: .long)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    private func setupTableView() {/* Core Data
         data = BirthPeopleManager().getPersistedBirthPeople()
         data = BirthComputer().compute(withBirthdayPeople: data!)
         tableView.reloadData()
         AppDelegate().syncWithAppleWatch()*/
        let request = PeopleToSave.sortedFetchRequest
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        data = frc.fetchedObjects as! [PeopleToSave]
        data = BirthComputer().compute(withBirthdayPeople: data)
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
            try! context.save()
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
            data = BirthComputer().compute(withBirthdayPeople: data)
            tableView.reloadData()
        case .delete:
            break // Already done in method tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle ...
        default:
            break // tan90
        }
    }
    
}
