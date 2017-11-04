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
        
        view.backgroundColor = UIColor.background
        
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
        
        tableView.tableFooterView = UIView()
        
        view.addSubview(loadingView)
        loadingView.start()
        loadAnimes()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnimeDetail" {
            let viewController = segue.destination as! GetPersonalDataFromServerViewController
            viewController.anime = sender as? Anime
            viewController.navigationItem.title = (sender as! Anime).name.replacingOccurrences(of: "\n", with: "")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.section
        performSegue(withIdentifier: "showAnimeDetail", sender: animes[index])
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return animes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "animeCell") as! AnimeCell
        if let image = animes[index].pic {
            cell.picView?.image = image
        }
        cell.nameLabel.text = animes[index].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @IBAction func other(_ sender: Any) {
        performSegue(withIdentifier: "customize", sender: nil)
    }
    
    func loadAnimes() {
        NetworkController.provider.request(.animes) { [weak self] response in
            DispatchQueue.main.async {
                self?.loadingView.stop()
            }
            switch response {
            case .success(let result):
                let json = String(data: result.data, encoding: String.Encoding.utf8)!
                self?.animes = Mapper<Anime>().mapArray(JSONString: json)!
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                self?.loadPicsForAnimes()
            case .failure(let error):
                self?.animes = []
                DispatchQueue.main.async {
                    let appearence = SCLAlertView.SCLAppearance(showCloseButton: false)
                    let alert = SCLAlertView(appearance: appearence)
                    alert.addButton("OK") { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    alert.showError("Failed to load", subTitle: error.localizedDescription)
                }
            }
        }
    }
    
    func loadPicsForAnimes() {
        animes.forEach { anime in
            NetworkController.provider.request(.animepic(withID: anime.id)) { [weak self] response in
                switch response {
                case .success(let result):
                    let data = result.data
                    anime.pic = UIImage(data: data)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
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
