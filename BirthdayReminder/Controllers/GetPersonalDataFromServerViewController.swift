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

class GetPersonalDataFromServerViewController: UIViewController {
    
    weak var context: NSManagedObjectContext! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate.context
    }
    var tableViewData = [People]()
    var anime:Anime?
    
    private var activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 150)), type: .orbit, color: .cell, padding: nil)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addAllButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.background
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints() { make in
            make.center.equalToSuperview()
        }
        
        loadPeople()
    }
    
    @IBAction func storeAll(_ sender: Any) {
        tableViewData.forEach { person in
            PeopleToSave.insert(into: context, name: person.name, birth: person.stringedBirth, picData: person.picData, shouldSync: false)
        }
        navigationController?.popViewController(animated: true)
        SKStoreReviewController.requestReview()
    }
    
    private func loadPeople() {
        activityIndicator.startAnimating()
        NetworkController.networkQueue.async { [weak self] in
            NetworkController.provider.request(.people(inAnimeID: self!.anime!.id)) { response in
                switch response {
                case .success(let result):
                    let json = String(data: result.data, encoding: String.Encoding.utf8)!
                    self?.tableViewData = Mapper<People>().mapArray(JSONString: json)!
                    DispatchQueue.main.async{
                        self?.activityIndicator.stopAnimating()
                        self?.tableView.reloadData()
                        self?.tableView.animate(animations: [AnimationType.from(direction: .bottom, offset: 40)])
                    }
                    self?.loadPicForPeople()
                case .failure(let error):
                    self?.tableViewData = []
                    DispatchQueue.main.async {
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
        self.tableViewData.forEach { [weak self] person in
            NetworkController.provider.request(.personalPic(withID: person.id!, inAnime: self!.anime!.id)) { response in
                switch response {
                case .success(let result):
                    let data = result.data
                    person.picData = data
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        if (self?.tableViewData.filter { $0.picData == nil }.count) == 0 {
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
        cell.nameLabel.text = cellData.name
        cell.birthLabel.text = cellData.stringedBirth.toLocalizedDate()
        if let imgData = cellData.picData {
            cell.picView.image = UIImage(data: imgData)
        } else {
            cell.picView.image = UIImage(image: UIImage(), scaledTo: CGSize(width: 100, height: 100))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let controller = PersonFormController()
        controller.setup(with: .new, person: tableViewData[index])
        navigationController?.pushViewController(controller, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
