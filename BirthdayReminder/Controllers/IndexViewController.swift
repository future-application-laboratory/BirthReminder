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
    var status = false
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        navigationController?.navigationBar.barTintColor = UIColor.bar
        navigationController?.navigationBar.tintColor = UIColor.tint
        emptyLabel.textColor = UIColor.label
        navigationController?.hidesNavigationBarHairline = true
        setupTableView()
        tableView.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "indexCell", for: indexPath) as! PersonalCell
        cell.setData(data[index])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.cell
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
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        let request = PeopleToSave.sortedFetchRequest
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        data = frc.fetchedObjects!
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
        tableView.visibleCells.forEach { cell in
            (cell as? PersonalCell)?.changeBirthLabel()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let person = anObject as! PeopleToSave
            data.append(person)
            data = BirthComputer.compute(withBirthdayPeople: data)
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
            emptyLabel.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            emptyLabel.isHidden = true
        }
    }
    
    
}
