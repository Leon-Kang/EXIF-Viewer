//
// Created by Leon Kang on 2019/11/7.
// Copyright (c) 2019 LeonKang. All rights reserved.
//

import Foundation
import Photos
import UIKit

let kImageBundlePath = "Image.Bundle"

open class AssetManager {
    public static func getImage(_ name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        var bundle = Bundle(for: AssetManager.self)

        if let resource = bundle.resourcePath,
           let resourceBundle = Bundle(path: resource + kImageBundlePath) {
            bundle = resourceBundle
        }
        return UIImage(named: name, in: bundle, compatibleWith:traitCollection) ?? UIImage()
    }

    public static func fetchImage(_ withVideos: Bool = false,
                                  _ completion: @escaping (_ assets: [PHAsset]) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }

        DispatchQueue.global(qos: .background).async {
            let fetchResult = (withVideos == true)
                    ? PHAsset.fetchAssets(with: PHFetchOptions())
                    : PHAsset.fetchAssets(with: .image, options: PHFetchOptions())

            if fetchResult.count > 0 {
                var assets = [PHAsset]()
                fetchResult.enumerateObjects { asset, i, pointer in
                    assets.insert(asset, at: 0)
                }

                DispatchQueue.main.async {
                    completion(assets)
                }
            }
        }
    }

    public static func resolveAsset(_ asset: PHAsset,
                                    size: CGSize = CGSize(width: 720, height: 1280),
                                    shouldPreferLowRes: Bool = false,
                                    completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true

        imageManager.requestImage(for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: requestOptions
        ) { (image: UIImage?, dictionary: [AnyHashable: Any]?) in
            if let info = dictionary, info["PHImageFileUTIKey"] == nil {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

    public static func resolveAssets(_ assets: [PHAsset],
                                     size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true

        var images = [UIImage]()
        for asset in assets {
            imageManager.requestImage(for: asset,
                    targetSize: size,
                    contentMode: .aspectFill,
                    options: requestOptions
            ) { (image: UIImage?, dictionary: [AnyHashable: Any]?) in
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
}