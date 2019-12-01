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
    var sourceData: [String: Any]?
    var exifDictionary: [String: Any]?
    var gpsDictionary: [String: Any]?
    var tiffDictionary: [String: Any]?
    var jfifDictionary: [String: Any]?
    var iptcDictionary: [String: Any]?
    var auxDictionary: [String: Any]?
    var commonDictionary: [String: Any]?

    var metaDataDictionary: [String: [String: Any]]

    var exif: ExifInfo?
    var GPS: GPSInfo?

    init(exif: ExifInfo) {
        self.exif = exif
        self.metaDataDictionary = [String: [String: Any]]()
    }

    init(_ dictionary: Dictionary<String, Any>) {
        self.sourceData = dictionary
        self.metaDataDictionary = [String: [String: Any]]()
        if let exif = dictionary[MetaDataRootKey.exif.rawValue] as? [String : Any] {
            self.exifDictionary = exif
            self.metaDataDictionary["EXIF"] = exif
            let exifInfo = ExifInfo(dictionary: exif)
            self.exif = exifInfo
        }
        if let gps = dictionary[MetaDataRootKey.gps.rawValue] as? [String : Any] {
            self.gpsDictionary = gps
            let gpsInfo = GPSInfo(gps)
            self.GPS = gpsInfo
            self.metaDataDictionary["GPS"] = gps
        }
        if let tiff = dictionary[MetaDataRootKey.tiff.rawValue] as? [String : Any] {
            self.tiffDictionary = tiff
            self.metaDataDictionary["TIFF"] = tiff
        }
        if let jfif = dictionary[MetaDataRootKey.jfif.rawValue] as? [String : Any] {
            self.jfifDictionary = jfif
            self.metaDataDictionary["JFIF"] = jfif
        }
        if let iptc = dictionary[MetaDataRootKey.iptc.rawValue] as? [String : Any] {
            self.iptcDictionary = iptc
            self.metaDataDictionary["IPTC"] = iptc
        }
        if let aux = dictionary[MetaDataRootKey.exifAux.rawValue] as? [String : Any] {
            self.auxDictionary = aux
            self.metaDataDictionary["EXIF AUX"] = aux
        }
        self.commonDictionary = self.sourceData?.filter { key, value in value is String }
        self.metaDataDictionary["Common"] = self.commonDictionary
    }
}
