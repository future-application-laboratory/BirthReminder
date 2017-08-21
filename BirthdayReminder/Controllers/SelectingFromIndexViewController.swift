//
//  SelectingFromIndexViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 12/08/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CoreData

class SelectingFromIndexViewController: UITableViewController {
    
    weak var delegate: AppDelegate! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate
    }
    weak var context: NSManagedObjectContext! {
        return delegate.context
    }
    var tableData: [PeopleToSave]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.flatGreen
        setupTableView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "addingAWFavouriteCell")
        cell.backgroundColor = UIColor.clear
        let layer = cell.imageView?.layer
        layer?.masksToBounds = true
        layer?.cornerRadius = 5
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        cell.textLabel?.textColor = UIColor.flatWhite
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
        cell.detailTextLabel?.textColor = UIColor.flatWhite
        
        let row = indexPath.row
        let current = tableData![row]
        cell.textLabel?.text = current.name
        cell.detailTextLabel?.text = current.birth.toLocalizedDate(withStyle: .long)
        if let data = current.picData {
            cell.imageView?.image = UIImage(data: data)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let defaults = UserDefaults()
        var saved = defaults.array(forKey: "AWFavourite") as? [Data] ?? []
        let current = tableData![row]
        saved.append(PeopleToTransfer(withName: current.name, birth: current.birth, picData: current.picData).encoded)
        defaults.set(saved, forKey: "AWFavourite")
        navigationController?.popViewController(animated: true)
        delegate.syncWithAppleWatch()
    }
    
    private func setupTableView() {
        let request = PeopleToSave.sortedFetchRequest
        tableData = try! context.fetch(request) as! [PeopleToSave]
        tableView.reloadData()
    }
    
}
