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
import DZNEmptyDataSet
import ObjectMapper

class AnimeGettingFromServerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var animes = [Anime]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        view.backgroundColor = UIColor.flatGreen
        
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
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let font = UIFont.boldSystemFont(ofSize: 20)
        return NSAttributedString(string: "Loading now", attributes: [NSAttributedStringKey.font:font, NSAttributedStringKey.foregroundColor:UIColor.flatWhite])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "loading2")
    }
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        let animeX = CABasicAnimation()
        animeX.keyPath = "transform.scale.x"
        animeX.fromValue = 1
        animeX.toValue = 2
        let animeY = CABasicAnimation()
        animeY.keyPath = "transform.scale.y"
        animeY.fromValue = 1
        animeY.toValue = 2
        let animeAlpha = CABasicAnimation()
        animeAlpha.keyPath = "opacity"
        animeAlpha.fromValue = 0
        animeAlpha.toValue = 1
        let group = CAAnimationGroup()
        group.animations = [animeX,animeY,animeAlpha]
        group.duration = 2
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        group.repeatCount = HUGE
        return group
    }
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func reloadSparator() {
        tableView.separatorStyle = animes.isEmpty ? .none : .singleLine
    }
    
    func loadAnimes() {
        NetworkController.provider.request(.animes) { response in
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

class RoundedSquareCanvas: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let pathRect = bounds.insetBy(dx: 1, dy: 1)
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 10)
        path.lineWidth = 3
        UIColor.darkGray.setFill()
        UIColor.lightGray.setStroke()
        path.fill()
        path.stroke()
    }
    
}

class LoadingView:UIView {
    let progressView = UIActivityIndicatorView()
    var square:RoundedSquareCanvas?
    let loadingLabel = UILabel()
    
    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        square = RoundedSquareCanvas(frame: frame)
        self.addSubview(progressView)
        self.addSubview(square!)
        self.addSubview(loadingLabel)
        self.bringSubview(toFront: square!)
        self.bringSubview(toFront: progressView)
        self.bringSubview(toFront: loadingLabel)
        progressView.color = UIColor.white
        progressView.backgroundColor = UIColor.gray
        progressView.center = self.center
        loadingLabel.text = text
        loadingLabel.textAlignment = .center
        loadingLabel.textColor = UIColor.white
        loadingLabel.font = UIFont(name: "Pingfang SC", size: 20)
        loadingLabel.snp.makeConstraints { constraint in
            constraint.bottom.equalTo(square!).offset(-10)
            constraint.centerX.equalTo(square!)
            constraint.height.equalTo(50)
        }
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, text: "Loading")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        progressView.startAnimating()
        loadingLabel.isHidden = false
        square?.isHidden = false
    }
    
    func stop() {
        progressView.stopAnimating()
        loadingLabel.isHidden = true
        square?.isHidden = true
    }
    
}
