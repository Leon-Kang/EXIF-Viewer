//
// Created by Leon Kang on 2019/11/20.
// Copyright (c) 2019 LeonKang. All rights reserved.
//

import Foundation

struct ExifInfo: Codable {
    var ApertureValue: Float?
    var ColorSpace: Int?
    var ComponentsConfiguration: [Int]?
    var Contrast: Int?
    var CustomRendered: Int?
    var DateTimeDigitized: String?
    var DateTimeOriginal: String?
    var DigitalZoomRatio: Int?
    var ExifVersion: [Int]?
    var ExposureBiasValue: Int?
    var ExposureMode: Int?
    var ExposureProgram: Int?
    var ExposureTime: Double?
    var FNumber: Int?
    var FileSource: Int?
    var Flash: Int?
    var FlashPixVersion: [Int]?
    var FocalLenIn35mmFil: Int?
    var FocalLength: Int?
    var FocalPlaneResolutionUnit: Int?
    var FocalPlaneXResolution: Float?
    var FocalPlaneYResolution: Float?
    var GainControl: Int?
    var ISOSpeedRatings: [Int]?
    var LightSource: Int?
    var MaxApertureValue: Int?
    var MeteringMode: Int?
    var PixelXDimension: Int?
    var PixelYDimension: Int?
    var Saturation: Int?
    var SceneCaptureType: Int?
    var SensingMethod: Int?
    var Sharpness: Int?
    var ShutterSpeedValue: Float?
    var SubjectDistRang: Int?
    var SubjectDistance: String?
    var SubsecTimeDigitize: Int?
    var SubsecTimeOriginal: String?
    var WhiteBalance: Int?

    enum CodingKeys: String, CodingKey {
        case ApertureValue
        case ColorSpace
        case ComponentsConfiguration
        case Contrast
        case CustomRendered
        case DateTimeDigitized
        case DateTimeOriginal
        case DigitalZoomRatio
        case ExifVersion
        case ExposureBiasValue
        case ExposureMode
        case ExposureProgram
        case ExposureTime
        case FNumber
        case FileSource
        case Flash
        case FlashPixVersion
        case FocalLenIn35mmFil
        case FocalLength
        case FocalPlaneResolutionUnit
        case FocalPlaneXResolution
        case FocalPlaneYResolution
        case GainControl
        case ISOSpeedRatings
        case LightSource
        case MaxApertureValue
        case MeteringMode
        case PixelXDimension
        case PixelYDimension
        case Saturation
        case SceneCaptureType
        case SensingMethod
        case Sharpness
        case ShutterSpeedValue
        case SubjectDistRang
        case SubjectDistance
        case SubsecTimeDigitize
        case SubsecTimeOriginal
        case WhiteBalance
    }

    init(dictionary: [String : Any]) {
        let valid = JSONSerialization.isValidJSONObject(dictionary)
        if valid {
            let data = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            let jsonStr = String(data: data, encoding: .utf8)
            print("exif JSON: \(String(describing: jsonStr))")
            let exif = try! JSONDecoder().decode(ExifInfo.self, from: data)
            self = exif
        }
    }
}
