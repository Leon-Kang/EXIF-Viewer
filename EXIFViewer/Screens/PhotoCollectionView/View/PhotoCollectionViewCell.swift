//
//  PhotoCollectionViewCell.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/9/24.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import UIKit

let kPhotoCellIdentifier = "kPhotoCellIdentifier"

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var livePhotoBadgeImageView: UIImageView!

    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    var livePhotoBadgeImage: UIImage? {
        didSet {
            livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }
    
    var representedAssetIdentifier: String!

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        livePhotoBadgeImageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
