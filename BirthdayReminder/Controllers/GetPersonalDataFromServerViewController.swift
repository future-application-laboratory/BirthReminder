//
//  ViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 13/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import CoreData

class GetPersonalDataFromServerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    weak var context: NSManagedObjectContext! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate.context
    }
    var tableViewData = [BirthPeople]()
    var anime:Anime?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addAllButton: UIBarButtonItem!
    
    let loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        view.addSubview(loadingView)
        loadingView.center = view.center
        
        tableView.backgroundView?.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        
        ReminderDataNetworkController().networkQueue.async {
            OperationQueue.main.addOperation {
                self.loadingView.start()
            }
            self.tableViewData = self.getDetailedData(withAnimes: [self.anime!])
            OperationQueue.main.addOperation {
                self.loadingView.alpha = 0.8
                self.tableView.separatorStyle = .singleLine
                self.loadingView.stop()
                self.tableView.reloadData()
            }
            self.tableViewData.forEach() { data in
                let pic = ReminderDataNetworkController().get(PicFromStringedUrl: data.picLink!)
                data.picData = UIImagePNGRepresentation(pic)!
                data.status = true
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
            OperationQueue.main.addOperation {
                self.addAllButton.isEnabled = true
                self.addAllButton.title = "Add all"
            }
        }
        
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
        cell.detailTextLabel?.text = data.stringedBirth
        if let imageData = data.picData {
            let image = UIImage(data: imageData)
            cell.imageView?.image = image
        }
        //Cell Customize
        let imageView = cell.imageView
        let layer = imageView?.layer
        layer?.masksToBounds = true
        layer?.cornerRadius = 5
        cell.backgroundView?.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func getDetailedData(withAnimes:[Anime]) -> [BirthPeople] {
        var finalResult = [BirthPeople]()
        withAnimes.forEach { anime in
            let start = anime.startCharacter
            let id = anime.id
            finalResult.append(contentsOf: ReminderDataNetworkController().getCharacters(InAnimeWithId: id, StartAt: start).map {$0})
        }
        return finalResult
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
            controller.personalData = sender as! BirthPeople
        }
    }
    
    @IBAction func storeAll(_ sender: Any) {
        tableViewData.forEach { person in
            PeopleToSave.insert(into: context, name: person.name, birth: person.stringedBirth, picData: person.picData)
        }
        let controller = (navigationController?.viewControllers[1] as! UITabBarController).viewControllers![1] as! AnimeGettingFromServerViewController
        controller.animes = controller.animes.filter { anime in
            anime.id != self.anime!.id
        }
        controller.tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
}
