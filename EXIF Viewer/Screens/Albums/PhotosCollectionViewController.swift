//
//  PhotosCollectionViewController.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/9/24.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import UIKit

public let kPhotosCollectionViewIdentifier = "kPhotosCollectionViewIdentifier"

public enum CellSizeStyle {
    public typealias RawValue = String
    
    case Big, Normal, Small
}

class PhotosCollectionViewController: UICollectionViewController {
    
    public var photos = [Photo]()

    var cellSizeStyle : CellSizeStyle = .Small
       
    var cellSizeDictionary = [CellSizeStyle : CGSize]()
    var cellItemSpcing : [CellSizeStyle : CGFloat] = [.Big : 16, .Normal : 8, .Small : 16.0]
       
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kPhotoCellIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

}

extension PhotosCollectionViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < photos.count {
            let photo = photos[indexPath.row]
            let infoViewController = UIStoryboard.viewController(.main, identifier: kInfoViewControllerIdentifier) as! ExifInfoViewController
            infoViewController.photo = photo
            self.navigationController?.pushViewController(infoViewController, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPhotoCellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        if indexPath.row < photos.count {
            cell.image = photos[indexPath.row].photoImage
        }
        #if DEBUG
        cell.backgroundColor = UIColor.red
        #endif
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = UICollectionReusableView()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSizeDictionary[cellSizeStyle]!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellItemSpcing[cellSizeStyle]!
    }
}
