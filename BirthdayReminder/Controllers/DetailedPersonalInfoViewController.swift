//
//  DetailedPersonalInfoViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class DetailedPersonalInfoFromServerViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var animeID: Int?
    weak var context: NSManagedObjectContext! {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate.context
    }
    
    var personalData = People(withName: "", birth: "01-01", picData: nil, id: nil)
    let monthDict = [
        1:31,
        2:29,
        3:31,
        4:30,
        5:31,
        6:30,
        7:31,
        8:31,
        9:30,
        10:31,
        11:30,
        12:31
    ]
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.barTintColor = UIColor.flatGreenDark
        tabBarController?.tabBar.tintColor = UIColor.flatBlackDark
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.flatWhiteDark
        
        view.backgroundColor = UIColor.flatGreen
        
        cancelButton.isHidden = (personalData.name == "")
        
        tableView.separatorStyle = .none
        
        clearButtonColorReload()
        
        if personalData.picData == nil && personalData.id != nil {
            NetworkController.networkQueue.async {
                NetworkController.provider.request(.personalPic(withID: self.personalData.id!, inAnime: self.animeID!)) { response in
                    switch response {
                    case .success(let result):
                        self.imageView.image = UIImage(data: result.data)
                    case .failure(let error):
                        self.dismiss(animated: true, completion: nil)
                        print(error.errorDescription!)
                    }
                }
            }
        }
        
        nameField.text = personalData.name
        
        if let imageData = personalData.picData {
            let image = UIImage(data: imageData)
            imageView.image = image
        }
        
        let birth = getIntBirth()
        pickerView.selectRow(birth.0, inComponent: 0, animated: true)
        pickerView.selectRow(birth.1, inComponent: 1, animated: true)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 12
        default:
            return monthDict[pickerView.selectedRow(inComponent: 0)+1]!
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (component == 0) ? NSLocalizedString("month\(row + 1)", comment: "localized month") : NSLocalizedString("day\(row + 1)", comment: "localized day")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
        var day = String(pickerView.selectedRow(inComponent: 1) + 1)
        var month = String(pickerView.selectedRow(inComponent: 0) + 1)
        if day.characters.count != 2 {
            day = "0" + day
        }
        if month.characters.count != 2 {
            month = "0" + month
        }
        personalData.stringedBirth = month + "-" + day
    }
    
    func getIntBirth() -> (Int,Int) {
        let stringedBirth = personalData.stringedBirth as NSString
        let month = stringedBirth.substring(to: 2)
        let day = stringedBirth.substring(from: 3)
        return (Int(month)! - 1,Int(day)! - 1)
    }
    
    @IBAction func onDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
        let picData = imageView.image != nil ? UIImagePNGRepresentation(imageView.image!) : nil
        PeopleToSave.insert(into: context, name: nameField.text!, birth: personalData.stringedBirth, picData: picData)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        clearButton.isEnabled = true
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        imageView.image = image
        personalData.picData = UIImagePNGRepresentation(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearPic(_ sender: Any) {
        imageView.image = UIImage()
        personalData.picData = nil
        clearButton.isEnabled = false
        clearButtonColorReload()
    }
    
    @IBAction func changePic(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.mediaTypes = [kUTTypeImage as String]
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        }else{
            print("Not able to access pics")
        }
    }
    
    func clearButtonColorReload() {
        clearButton.tintColor = clearButton.isEnabled ? UIColor.flatWhite : UIColor.flatWhiteDark
    }
    
}
