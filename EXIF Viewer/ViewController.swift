//
//  ViewController.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/9/24.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import UIKit
import Photos

public let kScreenHeight = UIScreen.main.bounds.height
public let kScreenWidth = UIScreen.main.bounds.width

extension UIStoryboard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    
    static func viewController(_ storyboard: UIStoryboard, identifier: String) -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}



class Photo: NSObject {
    var photoImage: UIImage?
    var title: String?
}

class Album: NSObject {
    var coverImage: UIImage?
    var title: String?
    var count: Int = 0
}

class ViewController: UIViewController {

    var collections = [PHAssetCollection]()
    var albums = [Album]()
    
    let photosCollectionView = UIStoryboard.viewController(.main, identifier: kPhotosCollectionViewIdentifier) as! PhotosCollectionViewController
    
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
    
    func getAlbumCovers(complateHandler: @escaping (_ coverAlbums: [Album]) -> Void) {
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
                    complateHandler(albums)
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
                                            complateHandler(albums)
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
                                          complateHandler: @escaping (_ photo: UIImage?) -> Void) {
        let coverSize = size
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = mode
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: coverSize,
                                              contentMode: .default,
                                              options: options) { result, info in
                                                guard result != nil else { return complateHandler(nil) }
                                                complateHandler(result)
        }
    }
    
    func getAlbumPhotos(albumCollection: PHAssetCollection,
                        complateHandler: @escaping (([Photo], PHFetchResult<PHAsset>) -> Void)) {
        let assets = albumPHAssets(albumCollection)
        var photos = [Photo]()

        for a_index in 0 ..< assets.count {
            let photo = Photo()
            convertPHAssetToUIImage(asset: assets[a_index],
                                    size: CGSize(width: 150, height: 150),
                                    mode: .highQualityFormat) { (photoImage) in
                                        photo.photoImage = photoImage
                                        photo.title = albumCollection.localizedTitle ?? ""
                                        photos.append(photo)

                                        if a_index == assets.count - 1 {
                                            complateHandler(photos, assets)
                                        }
            }
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row < collections.count {
            self.getAlbumPhotos(albumCollection: collections[row]) { (photos, result) in
                self.photosCollectionView.photos = photos
                self.navigationController?.pushViewController(self.photosCollectionView, animated: true)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kAlbumsCellIdentifier, for: indexPath) as! AlbumsTableViewCell
        let row = indexPath.row
        if row < albums.count {
            cell.photo = albums[row].coverImage
            cell.title = albums[row].title
        }
        return cell
    }
}
