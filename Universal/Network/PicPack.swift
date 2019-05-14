//
//  PicPack.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 2018/2/12.
//  Copyright © 2018 CaptainYukinoshitaHachiman. All rights reserved.
//

import UIKit
import ObjectMapper

final class PicPack: Mappable {

    private var base64: String!
    var picData: NSData? {
        return NSData(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    var copyright: String!
    var pic: UIImage? {
        guard let data = picData else { return nil }
        return UIImage(data: data as Data)
    }
    var data: Data? {
        guard let pic = pic else { return nil }
        return pic.pngData()
    }

    convenience init?(picData: Data) {
        guard let image = UIImage(data: picData) else { return nil }
        self.init(image: image, copyrightInfo: "")
    }

    required init?(map: Map) {
    }

    init?(image: UIImage, copyrightInfo: String) {
        guard let jpegData = image.jpegData(compressionQuality: 1) as NSData? else { return nil }
        base64 = jpegData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        copyright = copyrightInfo
    }

    func mapping(map: Map) {
        base64 <- map["pic"]
        copyright <- map["copyright"]
    }

    var objectForContribution: [String: Any]? {
        guard let image = pic,
            let resizedImage = UIImage(image: image, scaledTo: CGSize(width: 200, height: 200)),
            let resizedPack = PicPack(image: resizedImage, copyrightInfo: copyright) else { return nil }
        return ["base64": resizedPack.base64!, "copyright": copyright]
    }

}
