//
//  MetaData.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/11/13.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import Foundation

enum MetaDataRootKey: String {
    case exif = "{Exif}"
    case gps = "{GPS}"
    case tiff = "{TIFF}"
    case jfif = "{JFIF}"
    case iptc = "{IPTC}"
    case exifAux = "{ExifAux}"
}

public struct MetaData {
    var exif: ExifInfo?

    init(exif: ExifInfo) {
        self.exif = exif
    }

    init(_ dictionary: Dictionary<String, Any>) {
        if let dict = dictionary[MetaDataRootKey.exif.rawValue] as? [String : Any] {
            do {
                let exifInfo = try ExifInfo(dictionary: dict)
                self.exif = exifInfo
            } catch {
                print(error.localizedDescription)
            }
        } else {
            self.exif = nil
        }
    }
}
