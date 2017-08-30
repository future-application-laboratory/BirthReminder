//
//  ViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 13/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CoreData
import SCLAlertView
import ObjectMapper

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
        
        view.backgroundColor = UIColor.flatGreen
        
        tableView.separatorStyle = .none
        
        view.addSubview(loadingView)
        loadingView.center = view.center
        
        tableView.backgroundView?.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        
        tableView.tableFooterView = UIView()
        
        // Load the basic info
        loadingView.start()
        
        loadPeople()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "personalDetailFromAnime")
        //Data
        let row = indexPath.row
        let data = tableViewData[row]
        cell.textLabel?.text = data.name
        cell.detailTextLabel?.text = data.stringedBirth.toLocalizedDate(withStyle: .long)
        if let imageData = data.picData {
            let image = UIImage(data: imageData)
            cell.imageView?.image = image
        }
        //Cell Customize
        let imageView = cell.imageView
        let layer = imageView?.layer
        layer?.masksToBounds = true
        layer?.cornerRadius = 5
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
        cell.textLabel?.textColor = UIColor.flatWhite
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.textColor = UIColor.flatWhite
        cell.backgroundView?.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        performSegue(withIdentifier: "showCharacterDetail", sender: tableViewData[row])
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCharacterDetail" {
            let controller = segue.destination as! DetailedPersonalInfoFromServerViewController
            controller.personalData = sender as! People
            controller.animeID = anime!.id
        }
    }
    
    @IBAction func storeAll(_ sender: Any) {
        tableViewData.forEach { person in
            PeopleToSave.insert(into: context, name: person.name, birth: person.stringedBirth, picData: person.picData)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func reloadSparator() {
        tableView.separatorStyle = tableViewData.isEmpty ? .none : .singleLine
    }
    
    private func loadPeople() {
        NetworkController.networkQueue.async { [unowned self] in
            NetworkController.provider.request(.people(inAnimeID: self.anime!.id)) { response in
                switch response {
                case .success(let result):
                    let json = String(data: result.data, encoding: String.Encoding.utf8)!
                    self.tableViewData = Mapper<People>().mapArray(JSONString: json)!
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                        self.reloadSparator()
                        self.loadingView.stop()
                    }
                    self.loadPicForPeople()
                case .failure(let error):
                    self.tableViewData = []
                    DispatchQueue.main.async {
                        let appearence = SCLAlertView.SCLAppearance(showCloseButton: false)
                        let alert = SCLAlertView(appearance: appearence)
                        alert.addButton("OK") { [unowned self] in
                            self.navigationController?.popViewController(animated: true) // Go back to previous view if fails to load
                        }
                        alert.showError("Failed to load", subTitle: error.errorDescription ?? "Unknown")
                    }
                }
            }
        }
    }
    
    private func loadPicForPeople() {
        // Load pic for every person
        self.tableViewData.forEach { [unowned self] person in
            NetworkController.provider.request(.personalPic(withID: person.id!, inAnime: self.anime!.id)) { response in
                switch response {
                case .success(let result):
                    let data = result.data
                    person.picData = data
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        if (self.tableViewData.filter { $0.picData == nil }.count) == 0 {
                            // Enable ‘add all’ button
                            self.addAllButton.isEnabled = true
                            self.addAllButton.image = UIImage(named: "addAll")
                        }
                    }
                case .failure(let error):
                    print(error.errorDescription!)
                }
            }
        }
    }
    
}
