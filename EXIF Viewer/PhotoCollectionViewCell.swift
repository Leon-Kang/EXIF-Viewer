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

    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
