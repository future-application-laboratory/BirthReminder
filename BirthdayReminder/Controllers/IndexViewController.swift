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
    
    let context = createDataMainContext()
    @IBOutlet weak var tableView: UITableView!
    
    var data = [PeopleToSave]()
    var status = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clear
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    
    func setupTableView() {/* Core Data
         data = BirthPeopleManager().getPersistedBirthPeople()
         data = BirthComputer().compute(withBirthdayPeople: data!)
         tableView.reloadData()
         AppDelegate().syncWithAppleWatch()*/
        let request = PeopleToSave.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "birth", ascending: false)]
        if let people = try? context.fetch(request) as? [PeopleToSave] {
            data = people!
        }
        data = BirthComputer().compute(withBirthdayPeople: data)
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        tableView.reloadData()
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
            data.remove(at: row)
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        data = controller.fetchedObjects as! [PeopleToSave]
        data = BirthComputer().compute(withBirthdayPeople: data)
        tableView.reloadData()
    }
    
}
