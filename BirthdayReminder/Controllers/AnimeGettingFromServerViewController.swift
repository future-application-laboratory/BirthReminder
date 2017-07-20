//
//  AnimeGettingFromServerViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit

class AnimeGettingFromServerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var animes = [Anime]()

    let networkController = ReminderDataNetworkController()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView?.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        animes = networkController.getListOfAnimes()
        networkController.networkQueue.async {
            self.animes.forEach { anime in
                let pic = self.networkController.get(PicFromStringedUrl: anime.picLink)
                anime.pic = pic
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnimeDetail" {
            let viewController = segue.destination as! GetPersonalDataFromServerViewController
            viewController.anime = sender as? Anime
            viewController.navigationItem.title = (sender as! Anime).name
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        performSegue(withIdentifier: "showAnimeDetail", sender: animes[row])
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "animeCell")
        let row = indexPath.row
        let data = animes[row]
        let image = data.pic
        cell.textLabel?.text = data.name
        let imageView = cell.imageView
        imageView?.image = image
        let layer = imageView?.layer
        layer?.masksToBounds = true
        layer?.cornerRadius = 5
        cell.backgroundView?.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
