//
//  ViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 13/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

class GetPersonalDataFromServerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var tableViewData = [BirthPeople]()
    var anime:Anime?
    
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView?.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        tableViewData = getDetailedData(withAnimes: [anime!])
        tableView.reloadData()
        ReminderDataNetworkController().networkQueue.async {
            self.tableViewData.forEach() { data in
                let pic = ReminderDataNetworkController().get(PicFromStringedUrl: data.picLink)
                data.picData = UIImagePNGRepresentation(pic) ?? Data()
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "personalDetailFromAnime")
        let row = indexPath.row
        let data = tableViewData[row]
        let image = UIImage(data: data.picData)
        cell.textLabel?.text = data.name
        cell.detailTextLabel?.text = data.stringedBirth
        let imageView = cell.imageView
        imageView?.image = image
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
            let controller = segue.destination as! DetailedPersonalInfoViewController
            controller.personalData = sender as! BirthPeople
        }
    }
    
}

