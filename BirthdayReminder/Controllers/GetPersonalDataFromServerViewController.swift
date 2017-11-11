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

class GetPersonalDataFromServerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    weak var context: NSManagedObjectContext! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate.context
    }
    var tableViewData = [People]()
    var anime:Anime?
    var rotateDegree = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addAllButton: UIBarButtonItem!
    
    let loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.background
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        
        view.addSubview(loadingView)
        loadingView.center = view.center
        
        
        // Load the basic info
        loadingView.start()
        
        loadPeople()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SKStoreReviewController.requestReview()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.section
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
        let index = indexPath.section
        let controller = PersonFormController()
        controller.setup(with: .new, person: tableViewData[index])
        navigationController?.pushViewController(controller, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @IBAction func storeAll(_ sender: Any) {
        tableViewData.forEach { person in
            PeopleToSave.insert(into: context, name: person.name, birth: person.stringedBirth, picData: person.picData, shouldSync: false)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func reloadSparator() {
        tableView.separatorStyle = tableViewData.isEmpty ? .none : .singleLine
    }
    
    private func loadPeople() {
        NetworkController.networkQueue.async { [weak self] in
            NetworkController.provider.request(.people(inAnimeID: self!.anime!.id)) { response in
                switch response {
                case .success(let result):
                    let json = String(data: result.data, encoding: String.Encoding.utf8)!
                    self?.tableViewData = Mapper<People>().mapArray(JSONString: json)!
                    DispatchQueue.main.async{
                        self?.tableView.reloadData()
                        self?.reloadSparator()
                        self?.loadingView.stop()
                        self?.tableView.animate(animations: [AnimationType.zoom(scale: 0.5)])
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
