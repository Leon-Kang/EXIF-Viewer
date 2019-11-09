//
//  ViewController.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/9/24.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import UIKit
import Photos

struct Photo {
    var photoImage: UIImage?
    var title: String?
    var asset: PHAsset?
}

class Album: NSObject {
    var coverImage: UIImage?
    var title: String?
    var count: Int = 0
}

class AlbumViewController: UIViewController {
    
    enum Section: Int {
        case allPhotos, smartAlbums, userCollections
        
        static let count = 3
    }
    
    var allPhotos: PHFetchResult<PHAsset>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var nonEmptySmartAlbums: [PHAssetCollection] = []
    var userCollections: PHFetchResult<PHCollection>!
    var userAssetCollections: [PHAssetCollection] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "AlbumsTableViewCell", bundle: nil), forCellReuseIdentifier: kAlbumsCellIdentifier)
        
        AppPermissionManager.shared.checkPhotoLib { (success) in
            if success {
                
            }
        }
        
        allPhotos = AssetManager.allPhotos()
        smartAlbums = AssetManager.smartAlbums()
        nonEmptySmartAlbums = AssetManager.nonEmptyAlbums()
        userCollections = AssetManager.userColletions()
        userAssetCollections = AssetManager.userAssetColletions()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

}

// MARK: UITableView Delegate
extension AlbumViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kAlbumsCellIdentifier, for: indexPath) as! AlbumsTableViewCell
        
        cell.photo = nil
        
        switch Section(rawValue: indexPath.section)! {
            
        case .allPhotos:
            cell.title = "all photos"
            cell.count = allPhotos.count
            if allPhotos.count > 0 {
                AssetManager.resolveAsset(allPhotos.object(at: 0),
                                          size: CGSize(width: 72, height: 72),
                                          shouldPreferLowRes: true) { (thumnail) in
                                            cell.photo = thumnail
                }
            }
            return cell
            
        case .smartAlbums:
            let collection = nonEmptySmartAlbums[indexPath.row]
            cell.title = collection.localizedTitle
            cell.count = collection.count
            if let firstImage = collection.newestImage() {
                AssetManager.resolveAsset(firstImage,
                                          size: CGSize(width: 72, height: 72),
                                          shouldPreferLowRes: true) { (thumnail) in
                                            cell.photo = thumnail
                }
            }
            return cell
            
        case .userCollections:
            let assetCollection = userAssetCollections[indexPath.row]
            cell.title = assetCollection.localizedTitle
            cell.count = assetCollection.count
            if let firstImage = assetCollection.newestImage() {
                AssetManager.resolveAsset(firstImage,
                                          size: CGSize(width: 72, height: 72),
                                          shouldPreferLowRes: true) { (thumnail) in
                                            cell.photo = thumnail
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        var collection: PHCollection = PHCollection()
        var fetchResult: PHFetchResult<PHAsset> = allPhotos
        
        let photosCollectionView = UIStoryboard.viewController(.main, identifier: kPhotosCollectionViewIdentifier) as! PhotosCollectionViewController
        
        switch Section(rawValue:indexPath.section) {
        case .allPhotos, .none:
            break
        case .smartAlbums:
            collection = nonEmptySmartAlbums[row]
        case .userCollections:
            collection = userAssetCollections[row]
        }
        
        if let assetCollection = collection as? PHAssetCollection {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
        }
        
        photosCollectionView.fetchResult = fetchResult
        
        self.navigationController?.pushViewController(photosCollectionView, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = 1
        if nonEmptySmartAlbums.count > 0 {
            count += 1
        }
        if userAssetCollections.count > 0 {
            count += 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 1
        switch Section(rawValue: section) {
        case .allPhotos:
            break
        case .smartAlbums:
            count = nonEmptySmartAlbums.count
        case .userCollections:
            count = userAssetCollections.count
        case .none:
            count = 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    
}

// MARK: Photo lib observer

extension AlbumViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
            allPhotos = changeDetails.fetchResultAfterChanges
        }
        
        if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
            smartAlbums = changeDetails.fetchResultAfterChanges
            nonEmptySmartAlbums = AssetManager.nonEmptyAlbums()
        }
        
        if let changeDetails = changeInstance.changeDetails(for: userCollections) {
            userCollections = changeDetails.fetchResultAfterChanges
            userAssetCollections = AssetManager.userAssetColletions()
        }
        
        DispatchQueue.main.async {
           self.tableView.reloadData()
        }
    }
}
