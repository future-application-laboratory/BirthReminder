//
//  ViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 13/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CoreData
import ObjectMapper
import StoreKit
import ViewAnimator
import CFNotify
import NVActivityIndicatorView
import Moya_ObjectMapper

class GetPersonalDataFromServerViewController: ViewController, ManagedObjectContextUsing {
    var tableViewData = [People]()
    var anime:Anime?
    
    private var activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 150)), type: .orbit, color: .cell, padding: nil)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addAllButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        loadPeople()
    }
    
    @IBAction func storeAll(_ sender: Any) {
        tableViewData.forEach { person in
            PeopleToSave.insert(into: context, name: person.name, birth: person.stringedBirth, picData: person.picPack?.data, picCopyright: person.picPack?.copyright, shouldSync: false)
        }
        navigationController?.popViewController(animated: true)
        SKStoreReviewController.requestReview()
    }
    
    private func loadPeople() {
        activityIndicator.startAnimating()
        NetworkController.networkQueue.async { [weak self] in
            NetworkController.provider.request(.people(inAnimeID: self!.anime!.id)) { result in
                switch result {
                case .success(let response):
                    self?.tableViewData = (try? response.mapArray(People.self)) ?? []
                    DispatchQueue.main.async{
                        self?.activityIndicator.stopAnimating()
                        self?.tableView.reloadData()
                        self?.tableView.animate(animations: [AnimationType.from(direction: .bottom, offset: 40)])
                    }
                    self?.loadPicForPeople()
                case .failure(let error):
                    self?.tableViewData = []
                    DispatchQueue.main.async { [weak self] in
                        let cfView = CFNotifyView.cyberWith(title: NSLocalizedString("failedToLoad", comment: "FailedToLoad"), body: error.localizedDescription, theme: .fail(.light))
                        var config = CFNotify.Config()
                        config.initPosition = .top(.center)
                        config.appearPosition = .top
                        CFNotify.present(config: config, view: cfView)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func loadPicForPeople() {
        // Load pic for every person
        tableViewData.forEach { person in
            NetworkController.provider.request(.personalPic(withID: person.id!)) { result in
                switch result {
                case .success(let response):
                    person.picPack = try? response.mapObject(PicPack.self)
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                        if (self?.tableViewData.filter { $0.picPack == nil }.count) == 0 {
                            // Enable ‘add all’ button
                            self?.addAllButton.isEnabled = true
                            self?.addAllButton.image = UIImage(named: "addAll")
                        }
                    }
                case .failure(let error):
                    print(error.errorDescription!)
                }
            }
        }
    }
    
}

extension GetPersonalDataFromServerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cellData = tableViewData[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell", for: indexPath) as! PersonalCell
        cell.delegate = self
        if let picPack = tableViewData[index].picPack {
            cell.picPack = picPack
        }
        cell.nameLabel.text = cellData.name
        cell.birthLabel.text = cellData.stringedBirth.toLocalizedDate()
        cell.picPack = cellData.picPack
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let person = tableViewData[index]
        let controller = PersonFormController(with: .new(person))
        navigationController?.pushViewController(controller, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

extension GetPersonalDataFromServerViewController: CopyrightViewing {
    func showCopyrightInfo(_ info: String) {
        let cfView = CFNotifyView.cyberWith(title: NSLocalizedString("aboutThePic", comment: "AboutThePic"), body: info, theme: .info(.light))
        var config = CFNotify.Config()
        config.initPosition = .top(.center)
        config.appearPosition = .top
        config.hideTime = .default
        CFNotify.present(config: config, view: cfView)
    }
}
