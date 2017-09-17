//
//  AppleWatchSettingViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 11/08/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity
import SCLAlertView

class AppleWatchSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addButton: UIButton!
    
    weak var context: NSManagedObjectContext! {
        return delegate.context
    }
    
    weak var delegate: AppDelegate! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate
    }
    var saved: [PeopleToSave]?
    
    @IBOutlet weak var emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 200))
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        emptyLabel?.textColor = .label2
        
        if !WCSession.isSupported() {
            let appearence = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alert = SCLAlertView(appearance: appearence)
            alert.addButton("OK") {
                self.navigationController?.popViewController(animated: true)
            }
            alert.showWarning(NSLocalizedString("inavailable", comment: "Inavailable"), subTitle: NSLocalizedString("awNotSupported", comment: "Apple Watch not Supported"))
        }
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
        reloadAddButtonStatus()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return saved?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    private func reloadTableView() {
        let request = PeopleToSave.sortedFetchRequest
        saved = try! context.fetch(request).filter { person in
            person.shouldSync
        }
        tableView.reloadData()
        emptyLabel?.isHidden = !saved!.isEmpty
        tableView.separatorStyle = saved!.isEmpty ? .none : .singleLine
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
            let index = indexPath.section
            
            saved![index].shouldSync = false
            try! context.save()
            
            saved!.remove(at: index)
            tableView.reloadData()
            
            emptyLabel?.isHidden = !saved!.isEmpty
            tableView.separatorStyle = saved!.isEmpty ? .none : .singleLine
            reloadAddButtonStatus()
            delegate.syncWithAppleWatch()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.section
        let cellData = saved![index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell", for: indexPath) as! PersonalCell
        cell.nameLabel.text = cellData.name
        cell.birthLabel.text = cellData.birth.toLocalizedDate(withStyle: .long)
        if let imgData = cellData.picData {
            cell.picView.image = UIImage(data: imgData)
        } else {
            cell.picView.image = UIImage(image: UIImage(), scaledTo: CGSize(width: 100, height: 100))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func reloadAddButtonStatus() {
        addButton.isEnabled = (saved?.count ?? 0) < 10
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let sectionHeaderHeight: CGFloat = 20
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
        } else if scrollView.contentOffset.y >= sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsetsMake(CGFloat(-sectionHeaderHeight), 0, 0, 0)
        }
    }
    
}

