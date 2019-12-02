//
//  MetaData.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/11/13.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import Foundation
import CoreLocation

enum MetaDataRootKey: String {
    case exif = "{Exif}"
    case gps = "{GPS}"
    case tiff = "{TIFF}"
    case jfif = "{JFIF}"
    case iptc = "{IPTC}"
    case exifAux = "{ExifAux}"
}

struct BaseInfo {
    var DPIHeight: Int?
    var DPIWidth: Int?
    var colorModel: String?
    var pixelWidth: Float?
    var pixelHeight: Float?
    var depth: Float?
    var profileName: String?
    var orientation: Int?
    
    init(_ dictionary: Dictionary<String, Any>) {
        self.pixelWidth = dictionary["PixelWidth"] as? Float
        self.pixelHeight = dictionary["PixelHeight"] as? Float
        self.orientation = dictionary["Orientation"] as? Int
        self.depth = dictionary["Depth"] as? Float
        self.profileName = dictionary["ProfileName"] as? String
        self.colorModel = dictionary["ColorModel"] as? String
        self.DPIWidth = dictionary["DPIWidth"] as? Int
        self.DPIHeight = dictionary["DPIHeight"] as? Int
    }
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
    var location: CLLocation?
    
    var baseInfo: BaseInfo?

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
            
            var date = Date()
            let dateFormmatter = DateFormatter()
            dateFormmatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            if let dateStr = self.exif?.DateTimeOriginal {
                date = dateFormmatter.date(from: dateStr)!
            }
            
            if let lat = GPS?.latitude, let lon = GPS?.longitude, let latRef = GPS?.latitudeRef, let lonRef = GPS?.longitudeRef {
                
                self.location = CLLocation(latitude: latRef == "N" ? lat : -lat, longitude: lonRef == "E" ? lon : -lon)
            }
            
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
        self.commonDictionary = self.sourceData?.filter { key, value in !(value is Dictionary<String, Any>) }
        self.metaDataDictionary["Common"] = self.commonDictionary
        if let common = commonDictionary {
            self.baseInfo = BaseInfo(common)
        }
    }
}
