//
//  MiscViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 10/08/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import AcknowList
import WatchConnectivity
import Moya

class MiscViewController: UITableViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentingViewController.shared = self
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let path = Bundle.main.path(forResource: "Pods-BirthdayReminder-acknowledgements", ofType: "plist")
            let controller = AcknowsController(acknowledgementsPlistPath: path)
            //  swiftlint:disable line_length
            controller.acknowledgements! += [
                Acknow(title: "Material Icons",
                       text: "Icons in the app are from Google Materail Icons.\nThe icons are available under the Apache License Version 2.0. We'd love attribution in your app's \"about\" screen, but it's not required. The only thing we ask is that you not re-sell these icons. https://material.io/icons/",
                       license: "apache-2.0"),
                Acknow(title: "OpenCC",
                       text: "The Traditional Chinese Localization are converted from Simplefied Chinese by OpenCC, which is licenced under Apache License 2.0 https://github.com/BYVoid/OpenCC",
                       license: "apache-2.0"),
                Acknow(title: "Pics on the Server",
                       text: "All the pics on the server are collected from the Internet, if you own the copyright/copyleft and don't want to see it here, please contact us at support@fal.moe")
            ]
            //  swiftlint:enable line_length
            navigationController?.pushViewController(controller, animated: true)
        case 2:
            let alertController = UIAlertController(title: NSLocalizedString("Feedback", comment: "feedback"),
                                                    message: NSLocalizedString("Give us suggestions", comment: "Give us Suggestions"),
                                                    preferredStyle: .alert)
            alertController.addTextField { _ in }
            alertController.addAction(UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default) { _ in
                if let field = alertController.textFields?.first {
                    self.submitFeedback(field.text!)
                }
            })
            alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel) { _ in })
            present(alertController, animated: true, completion: nil)
            tableView.reloadData()
        case 3:
            present(tutorialController, animated: true, completion: nil)
        case 4:
            if let navigationController = tabBarController?.viewControllers?.first as? UINavigationController,
                let indexController = navigationController.viewControllers.first as? IndexViewController {
                navigationController.popToRootViewController(animated: true)
                indexController.startContributingIfNotAlready()
                tabBarController?.selectedIndex = 0
            }
        default:
            break
        }
    }

    private func submitFeedback(_ feedback: String) {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "remoteToken")
        let content = feedback + "\ntoken: \(token ?? "not set")"
        let service = SlackService.feedback(content: content)
        NetworkController.networkQueue.async {
            MoyaProvider<SlackService>().request(service) { [weak self] result in
                switch result {
                case .success:
                    break
                case .failure:
                    self?.submitFeedback(feedback)
                }
            }
        }
    }

}

class AcknowsController: AcknowListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 32, weight: .semibold)
        ]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let acknowledgements = acknowledgements,
            let acknowledgement = acknowledgements[(indexPath as NSIndexPath).row] as Acknow?,
            let navigationController = self.navigationController {
            let viewController = AcknowController(acknowledgement: acknowledgement)
            navigationController.pushViewController(viewController, animated: true)
        }
    }

}

class AcknowController: AcknowViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

}
