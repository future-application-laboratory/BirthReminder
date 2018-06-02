//
//  AnimeGettingFromServerViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import SnapKit
import ObjectMapper
import ViewAnimator
import CFNotify
import NVActivityIndicatorView

class AnimeGettingFromServerViewController: ViewController {

    private var requirements: String?
    private var showsAllAnimes: Bool {
        return requirements?.isEmpty == true
    }

    private var animes = [Anime]() {
        didSet {
            loadPicsForAnimes()
        }
    }
    private var allAnimes = [Anime]()

    private let activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: .zero,
                                                                          size: CGSize(width: 150, height: 150)),
                                                            type: .orbit, color: .cell, padding: nil)

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        // Agreement
        let defaults = UserDefaults()
        if !defaults.bool(forKey: "shouldHideAgreement") {
            //  swiftlint:disable line_length
            let cfView = CFNotifyView.cyberWith(title: NSLocalizedString("about", comment: "about"),
                                                body: NSLocalizedString("agreement", comment: "The infomation and pictures are collected from the Internet, and they don't belong to the app's developer.\nPlease email me if you think things here are infringing your right, and I'll remove them. (You may see my contact info in the App Store Page, or the about page from index)"),
                                                theme: .warning(.light))
            //  swiftlint:enable line_length
            var config = CFNotify.Config()
            config.initPosition = .top(.center)
            config.appearPosition = .top
            config.hideTime = .never
            CFNotify.present(config: config, view: cfView)

            defaults.set(true, forKey: "shouldHideAgreement")
        }

        tableView.backgroundView?.backgroundColor = .clear
        tableView.backgroundColor = .clear

        tableView.separatorStyle = .none

        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        loadAnimes()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnimeDetail",
            let viewController = segue.destination as? GetPersonalDataFromServerViewController,
            let anime = sender as? Anime {
            viewController.anime = anime
            viewController.navigationItem.title = anime.name.replacingOccurrences(of: "\n", with: "")
        }
    }

    func loadAnimes() {
        activityIndicator.stopAnimating()
        if showsAllAnimes {
            animes = allAnimes
            tableView.reloadData()
            if !animes.isEmpty { return }
        } else {
            animes = []
            tableView.reloadData()
        }
        activityIndicator.startAnimating()
        NetworkController.provider.request(.animes(requirements: requirements)) { [weak self] result in
            switch result {
            case .success(let response):
                self?.animes = (try? response.mapArray(Anime.self)) ?? []
                if self?.showsAllAnimes == true {
                    self?.allAnimes = self?.animes ?? []
                }
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.reloadData()
                    self?.tableView.animate(animations: [AnimationType.from(direction: .bottom, offset: 40)])
                }
            case .failure(let error):
                self?.animes = []
                DispatchQueue.main.async { [weak self] in
                    let cfView = CFNotifyView.cyberWith(title: NSLocalizedString("failedToLoad", comment: "FailedToLoad"),
                                                        body: error.localizedDescription, theme: .fail(.light))
                    var config = CFNotify.Config()
                    config.initPosition = .top(.center)
                    config.appearPosition = .top
                    CFNotify.present(config: config, view: cfView)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    func loadPicsForAnimes() {
        animes.forEach { anime in
            NetworkController.provider.request(.animepic(withID: anime.id)) { [weak self] result in
                switch result {
                case .success(let response):
                    anime.picPack = try? response.mapObject(PicPack.self)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.errorDescription!)
                }
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // TODO: We should consider report this as a bug since
        // this would be expected bahavior (than black screen)
        navigationItem.searchController?.isActive = false
    }

}

extension AnimeGettingFromServerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        performSegue(withIdentifier: "showAnimeDetail", sender: animes[index])
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "animeCell")
        guard let animeCell = cell as? AnimeCell else { fatalError() }
        animeCell.delegate = self
        animeCell.picPack = animes[index].picPack
        animeCell.nameLabel.text = animes[index].name
        return animeCell
    }

}

extension AnimeGettingFromServerViewController: CopyrightViewing {
    func showCopyrightInfo(_ info: String) {
        let cfView = CFNotifyView.cyberWith(title: NSLocalizedString("aboutThePic", comment: "AboutThePic"),
                                            body: info, theme: .info(.light))
        var config = CFNotify.Config()
        config.initPosition = .top(.center)
        config.appearPosition = .top
        config.hideTime = .default
        CFNotify.present(config: config, view: cfView)
    }
}

extension AnimeGettingFromServerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        requirements = searchController.searchBar.text
        loadAnimes()
    }
}
