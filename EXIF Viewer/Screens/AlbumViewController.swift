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
    let sectionLocalizedTitles = ["a", "b", "c"]

    var collections = [PHAssetCollection]()
    var albums = [Album]()
    var photos = [PHAsset]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.register(UINib(nibName: "AlbumsTableViewCell", bundle: nil), forCellReuseIdentifier: kAlbumsCellIdentifier)
        
        AppPermissionManager.shared.checkPhotoLib { (success) in
            if success {
                self.collections = self.allAlbumCollection()
                self.getAlbumCovers { (albums) in
                    self.albums = albums
                    self.tableView.reloadData()
                }
                
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

    private func allAlbumCollection() -> [PHAssetCollection] {
        var collections = [PHAssetCollection]()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .any,
                                                                  options: nil) as! PHFetchResult<PHCollection>
        let userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: nil)

        for album in [smartAlbums, userAlbums] {
            for s_i in 0 ..< album.count {
                let collection = album[s_i] as! PHAssetCollection
                let types: [PHAssetCollectionSubtype] = [ .albumRegular,
                                                          .smartAlbumPanoramas,
                                                          .smartAlbumScreenshots,
                                                          .smartAlbumUserLibrary,
                                                          .smartAlbumRecentlyAdded
                ]
                if types.contains(collection.assetCollectionSubtype) {
                    collections.append(collection)
                }
            }
        }
        return collections
    }
    
    func getAlbumCovers(completeHandler: @escaping (_ coverAlbums: [Album]) -> Void) {
        let albumCollections = collections
        var albums = [Album](repeating: Album(), count: collections.count)
        
        var emptyCollectionsCount = 0
        var notEmptyCount = 0
        for (index, collection) in albumCollections.enumerated() {
            let assets = albumPHAssets(collection)
            
            let album = Album()
            album.count = assets.count
            album.title = collection.localizedTitle
            
            guard assets.count != 0 else {
                emptyCollectionsCount += 1
                album.coverImage = UIImage()
                albums.insert(album, at: index)
                if albumCollections.count == emptyCollectionsCount + notEmptyCount {
                    completeHandler(albums)
                }
                continue
            }
            notEmptyCount += 1
            convertPHAssetToUIImage(asset: assets[0],
                                    size: CGSize(width: 150, height: 150),
                                    mode: .fastFormat) { (image) in
                                        album.coverImage = image
                                        albums.insert(album, at: index)

                                        if albumCollections.count == emptyCollectionsCount + notEmptyCount {
                                            completeHandler(albums)
                                        }
            }
        }
    }
    
    private func albumPHAssets(_ collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(in: collection, options: options)
        return fetchResult
    }
    
    func convertPHAssetToUIImage(asset: PHAsset,
                                 size: CGSize,
                                 mode: PHImageRequestOptionsDeliveryMode,
                                 completeHandler: @escaping (_ photo: UIImage?) -> Void) {
        let coverSize = size
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = mode
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: coverSize,
                                              contentMode: .default,
                                              options: options) { result, info in
                                                guard result != nil else { return completeHandler(nil) }
                                                completeHandler(result)
        }
    }
    
    func getAlbumPhotos(albumCollection: PHAssetCollection,
                        completeHandler: @escaping (([Photo], PHFetchResult<PHAsset>) -> Void)) {
        let assets = albumPHAssets(albumCollection)
        var photos = [Photo]()

        for a_index in 0 ..< assets.count {
            var photo = Photo()
            convertPHAssetToUIImage(asset: assets[a_index],
                                    size: CGSize(width: 150, height: 150),
                                    mode: .highQualityFormat) { (photoImage) in
                                        photo.asset = assets[a_index]
                                        photo.photoImage = photoImage
                                        photo.title = albumCollection.localizedTitle ?? ""
                                        photos.append(photo)

                                        if a_index == assets.count - 1 {
                                            completeHandler(photos, assets)
                                        }
            }
        }
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
                                          completion: { (thumnail) in
                                            cell.photo = thumnail
                })
            }
            return cell
            
        case .smartAlbums:
            let collection = nonEmptySmartAlbums[indexPath.row]
            cell.title = collection.localizedTitle
            cell.count = collection.count
            if let firstImage = collection.newestImage() {
                AssetManager.resolveAsset(firstImage) { (thumnail) in
                    cell.photo = thumnail
                }
            }
            return cell
            
        case .userCollections:
            let assetCollection = userAssetCollections[indexPath.row]
            cell.title = assetCollection.localizedTitle
            cell.count = assetCollection.count
            if let firstImage = assetCollection.newestImage() {
                AssetManager.resolveAsset(firstImage) { (thumnail) in
                    cell.photo = thumnail
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row < collections.count {
            self.getAlbumPhotos(albumCollection: collections[row]) { (photos, result) in
                let photosCollectionView = UIStoryboard.viewController(.main, identifier: kPhotosCollectionViewIdentifier) as! PhotosCollectionViewController
                photosCollectionView.photos = photos
                self.navigationController?.pushViewController(photosCollectionView, animated: true)
            }
        }
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
