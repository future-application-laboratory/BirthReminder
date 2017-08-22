//
//  AppleWatchSettingViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 11/08/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CoreData

class AppleWatchSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addButton: UIButton!
    
    weak var delegate: AppDelegate! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate
    }
    var saved: [PeopleToTransfer]?
    
    @IBOutlet weak var emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 200))
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.flatGreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
        reloadAddButtonStatus()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let people = saved {
            return people.count
        }
        return 0
    }
    
    private func reloadTableView() {
        let defaults = UserDefaults()
        saved = (defaults.array(forKey: "AWFavourite") as? [Data] ?? []).map { person in
            person.toPeopleToTransfer()!
        }
        tableView.reloadData()
        emptyLabel?.isHidden = !saved!.isEmpty
        tableView.separatorStyle = saved!.isEmpty ? .none : .singleLineEtched
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = indexPath.row
            saved!.remove(at: row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            let defaults = UserDefaults()
            defaults.set(saved!.map { person in
                person.encoded
            }, forKey: "AWFavourite")
            emptyLabel?.isHidden = !saved!.isEmpty
            tableView.separatorStyle = saved!.isEmpty ? .none : .singleLineEtched
            reloadAddButtonStatus()
            delegate.syncWithAppleWatch()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "awFavouriteCell")
        cell.backgroundColor = UIColor.clear
        let layer = cell.imageView?.layer
        layer?.masksToBounds = true
        layer?.cornerRadius = 5
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
        cell.textLabel?.textColor = UIColor.flatWhite
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.textColor = UIColor.flatWhite
        
        let row = indexPath.row
        let current = saved![row]
        cell.textLabel?.text = current.name
        cell.detailTextLabel?.text = current.birth.toLocalizedDate(withStyle: .long)
        if let data = current.picData {
            cell.imageView?.image = UIImage(data: data)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func reloadAddButtonStatus() {
        addButton.isEnabled = (saved?.count ?? 0) < 10
    }
    
}

