//
//  DetailedPersonalInfoViewController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 17/07/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import MobileCoreServices

class DetailedPersonalInfoFromServerViewController: UITableViewController,UIPickerViewDelegate,UIPickerViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    var personalData = BirthPeopleManager().creatBirthPeople(name: "", stringedBirth: "01-01", picData: Data())
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
    
    var newPersonalData = BirthPeople()
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        if !personalData.status && personalData.picLink != ""{
            let image = ReminderDataNetworkController().get(PicFromStringedUrl: personalData.picLink)
            personalData.picData = UIImagePNGRepresentation(image)!
            personalData.status = true
        }
        
        clearButton.isEnabled = (personalData.picData != Data())
        nameField.text = personalData.name
        imageView.image = UIImage(data: personalData.picData)
        
        let birth = getIntBirth()
        pickerView.selectRow(birth.0, inComponent: 0, animated: true)
        pickerView.selectRow(birth.1, inComponent: 1, animated: true)
        
        newPersonalData = BirthPeopleManager().creatBirthPeople(name: personalData.name, stringedBirth: personalData.stringedBirth, picData: personalData.picData)
        newPersonalData.status = true
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
            day = " " + day
        }
        if month.characters.count != 2 {
            month = "" + month
        }
        newPersonalData.stringedBirth = month + "-" + day
    }
    
    func getIntBirth() -> (Int,Int) {
        let stringedBirth = personalData.stringedBirth as NSString
        let month = stringedBirth.substring(to: 2)
        let day = stringedBirth.substring(from: 3)
        return (Int(month)! - 1,Int(day)! - 1)
    }
    
    @IBAction func onDone(_ sender: Any) {
        if (navigationController?.viewControllers[1] as! UITabBarController).viewControllers![0] is DetailedPersonalInfoFromServerViewController{
            navigationController?.popViewController(animated: true)
        }else{
            let controller = (navigationController?.viewControllers[1] as! UITabBarController).viewControllers![1] as! GetPersonalDataFromServerViewController
            controller.tableViewData = controller.tableViewData.filter { person in
                person.name != personalData.name
            }
            dismiss(animated: true, completion: nil)
        }
        BirthPeopleManager().persist(Person: newPersonalData)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        clearButton.isEnabled = true
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        imageView.image = image
        newPersonalData.picData = UIImagePNGRepresentation(image) ?? Data()
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
        newPersonalData.picData = Data()
        clearButton.isEnabled = false
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
    
}
