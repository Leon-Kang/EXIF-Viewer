//
//  MetaDataManager.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/11/13.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import Foundation
import Photos
import UIKit

enum ErrorType: Int {
    case none ,noURL, edition, save
}

protocol CustomErrorProtocol: LocalizedError {
    var title: String? { get }
    var type: ErrorType { get }
}

public struct CustomError: CustomErrorProtocol {

    private(set) var title: String? = nil
    private(set) var type: ErrorType = .none
}

public class MetaDataManager {

    var asset: PHAsset!
    var editingInputRequestId: PHContentEditingInputRequestID?

    init(asset: PHAsset) {
        self.asset = asset
    }

    public func getOrientationMetaData(_ completion: @escaping (_ metaData: Dictionary<String, Any>) -> Void) {
        self.getOrientationMetaData(asset
        ) { result in
            completion(result)
        }
    }

    public func getOrientationMetaData(_ asset: PHAsset,
                                       _ completion: @escaping (_ metaData: Dictionary<String, Any>) -> Void) {
        getFullSizeImageUrl(asset) { url, error in
            if let url = url,
               let ciImage = CIImage(contentsOf: url) {
                completion(ciImage.properties)
            }
        }
    }

    public func getFullSizeImageUrl(_ asset: PHAsset,
                                    _ options: PHContentEditingInputRequestOptions =
                                    PHContentEditingInputRequestOptions(),
                                    _ completion: @escaping (_ url: URL?, _ error: CustomError?) -> Void) {
        editingInputRequestId = asset.requestContentEditingInput(with: options
        ) { editingInput, dictionary in
            guard let url = editingInput?.fullSizeImageURL else {
                completion(.none, CustomError(type: .noURL))
                return
            }
            completion(url, .none)
        }
    }
}
