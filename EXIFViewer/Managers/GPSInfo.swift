//
// Created by LeonKang on 2019/12/1.
// Copyright (c) 2019 LeonKang. All rights reserved.
//

import Foundation

struct GPSInfo: Codable {
    var latitude: Float = 0
    var longitude: Float = 0
    var altitude: Float = 0
//    var GPSVersion: String?

    enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
        case altitude = "Altitude"
//        case GPSVersion
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
