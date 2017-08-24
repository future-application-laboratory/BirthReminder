//
//  AnimeGettingFromServerViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import SnapKit
import SCLAlertView
import ObjectMapper

class AnimeGettingFromServerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var animes = [Anime]()
    
    @IBOutlet weak var tableView: UITableView!
    let loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.flatGreen
        
        loadingView.center = view.center
        
        // Agreement
        let defaults = UserDefaults()
        if !defaults.bool(forKey: "shouldHideAgreement") {
            let appearence = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alert = SCLAlertView(appearance: appearence)
            alert.addButton("Cancel") {
                self.navigationController?.popViewController(animated: true)
            }
            alert.addButton("Got it") {
                defaults.set(true, forKey: "shouldHideAgreement")
            }
            alert.showNotice("About", subTitle: NSLocalizedString("agreement", comment: "The infomation and pictures are collected from the Internet, and they don't belong to the app's developer.\nPlease email me if you think things here are infringing your right, and I'll remove them. (You may see my contact info in the App Store Page, or the about page from index)"))
        }
        
        tableView.backgroundView?.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        
        reloadSparator()
        
        view.addSubview(loadingView)
        loadingView.start()
        loadAnimes()
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
        cell.textLabel?.textColor = UIColor.flatWhite
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18.5, weight: UIFont.Weight.medium)
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
    
    @IBAction func other(_ sender: Any) {
        performSegue(withIdentifier: "customize", sender: nil)
    }
    
    func reloadSparator() {
        tableView.separatorStyle = animes.isEmpty ? .none : .singleLine
    }
    
    func loadAnimes() {
        NetworkController.provider.request(.animes) { response in
            DispatchQueue.main.async {
                self.loadingView.stop()
            }
            switch response {
            case .success(let result):
                let json = String(data: result.data, encoding: String.Encoding.utf8)!
                self.animes = Mapper<Anime>().mapArray(JSONString: json)!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.reloadSparator()
                }
                self.loadPicsForAnimes()
            case .failure(let error):
                self.animes = []
                DispatchQueue.main.async {
                    let appearence = SCLAlertView.SCLAppearance(showCloseButton: false)
                    let alert = SCLAlertView(appearance: appearence)
                    alert.addButton("OK") {
                        self.navigationController?.popViewController(animated: true)
                    }
                    alert.showError("Failed to load", subTitle: error.errorDescription ?? "Unknown")
                }
            }
        }
    }
    
    func loadPicsForAnimes() {
        animes.forEach { anime in
            NetworkController.provider.request(.animepic(withID: anime.id)) { response in
                switch response {
                case .success(let result):
                    let data = result.data
                    anime.pic = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.errorDescription!)
                }
            }
        }
    }
    
}
