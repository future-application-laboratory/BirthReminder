//
//  PersonFormController.swift
//  BirthdayReminder
//
//  Created by Jacky Yu on 16/09/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import CoreData
import SnapKit

class PersonFormController: FormViewController {
    
    public var data: People?
    
    private var context: NSManagedObjectContext {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate.context
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Name")
            <<< NameRow() { row in
                row.tag = "name"
                row.title = NSLocalizedString("name", comment: "name")
                row.placeholder = NSLocalizedString("name", comment: "name")
                if let name = data?.name {
                    row.value = name
                }
            }
            +++ Section("Birth")
            <<< DateRow() { row in
                row.tag = "birth"
                row.title = "Birth"
                row.value = Date()
                if let birth = data?.stringedBirth {
                    row.value = birth.toDate()
                }
            }
            +++ Section("Image")
            <<< ImageRow() { row in
                row.tag = "image"
                row.title = "Image"
                if let imageData = data?.picData {
                    row.value = UIImage(data: imageData)
                }
            }
            +++ Section()
            <<< ButtonRow() { row in
                row.title = "Done"
            }
    }
    
    private func save() {
        let values = form.values()
        let name = values["name"] as! String?
        let birth = values["birth"] as! Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        let stringBirth = formatter.string(from: birth)
        let image = values["image"] as! UIImage?
        let imageData = UIImagePNGRepresentation(image ?? UIImage())
        PeopleToSave.insert(into: context, name: name ?? "", birth: stringBirth, picData: imageData)
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            save()
        }
    }
    
}
