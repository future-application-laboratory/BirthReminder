//
//  IndexViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 20/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import RealmSwift

class IndexViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var data:[BirthPeople]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upDateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        upDateData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "mainCell")
        let person = self.data![indexPath.row]
        cell.textLabel?.text = person.name
        cell.detailTextLabel?.text = person.stringedBirth
        cell.imageView?.image = UIImage(data: person.picData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func upDateData() {
        data = BirthPeopleManager().getPersistedBirthPeople()
        tableView.reloadData()
    }
    
}
