//
// Created by LeonKang on 2019/12/1.
// Copyright (c) 2019 LeonKang. All rights reserved.
//

import Foundation

struct GPSInfo: Codable {
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var latitudeRef: String?
    var longitudeRef: String?
    var imgDirection: Double?
    var imgDirectionRef: String?
    
    var speed: Double?
    var speedRef: String?
    
    var MapDatum: String?
    var GPSVersion: Array<Int>?

    enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
        case altitude = "Altitude"
        case imgDirection = "ImgDirection"
        case imgDirectionRef = "ImgDirectionRef"
        case latitudeRef = "LatitudeRef"
        case longitudeRef = "LongitudeRef"
        
        case speed = "Speed"
        case speedRef = "SpeedRef"
        
        case GPSVersion
        case MapDatum
    }

    init(_ dictionary: [String : Any]) {
        let valid = JSONSerialization.isValidJSONObject(dictionary)
        if valid {
            let data = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            let gps = try! JSONDecoder().decode(GPSInfo.self, from: data)
            self = gps
        }
    }
}
