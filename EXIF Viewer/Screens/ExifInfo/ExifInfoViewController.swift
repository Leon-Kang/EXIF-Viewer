//
//  ExifInfoViewController.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/9/24.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import UIKit
import Photos

public let kInfoViewControllerIdentifier = "kInfoViewControllerIdentifier"

class ExifInfoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = [String: Any]()
    
    public var image: UIImage? {
        didSet {
            updateUI()
        }
    }
    
    public var photo: Photo? {
        didSet {
            if let asset = photo?.asste {
                self.getFullSizeAsset(asset: asset)
            }
        }
    }
    
    private let imagePicker: UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func updateUI() {
        self.imageView.image = image
        self.tableView.reloadData()
    }
    
    @IBAction func openPhotoLib(_ sender: Any) {
        AppPermissionManager.shared.checkPhotoLib { (result) in
            if result == true {
                DispatchQueue.main.async {
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }
    }

}

extension ExifInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func getFullSizeAsset(asset: PHAsset) {
        asset.requestContentEditingInput(with: nil) { [weak self] (input, result) in
            if let url = input?.fullSizeImageURL {
                self?.getOritationImage(imageUrl: url)
            }
            
        }
    }
    
    func getOritationImage(imageUrl: URL) {
        let image = CIImage(contentsOf: imageUrl)
        if let image = image {
            self.image = UIImage(ciImage: image)
        }
        if let metaData = image?.properties {
            self.dataSource = flattenDictionary(dic: metaData)
            let sorted = self.dataSource.sorted { (value1, value2) -> Bool in
                return value1.key < value2.key
            }
            self.dataSource = Dictionary()
            for (key, value) in sorted {
                self.dataSource[key] = value
            }
            self.updateUI()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let asset = info[.phAsset] as? PHAsset {
            self.getFullSizeAsset(asset: asset)
        }
        
        if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 1.0) {
            self.image = image
            
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }
            guard let metaData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? Dictionary<String, Any> else { return }
//            dataSource = flattenDictionary(dic: NSDictionary(dictionary: metaData) as! [String : Any])
//
//            updateUI()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ExifInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "kCellIdentifier") as? InfoTableViewCell
        if cell == nil {
            cell = InfoTableViewCell(style: .default, reuseIdentifier: "kCellIdentifier")
        }
        let row = indexPath.row
        if row < dataSource.count {
            let keys = Array(dataSource.keys)
            let key = keys[row]
            cell?.titleLabel.text = key
            cell?.titleLabel.sizeToFit()
            if let value = dataSource[key] {
                cell?.valueLabel.text = "\(value)"
                cell?.valueLabel.numberOfLines = 0
                cell?.valueLabel.sizeToFit()
            }
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

func flattenDictionary(dic: [String: Any], keepLevel: UInt = UInt.max) -> [String: Any] {
    var result: [String: Any] = [:]
    func flattenDic(_ dic: [String: Any], out: inout [String: Any], level: UInt, addedKey: String = "") {
        if level == 0 { return }
        for (key, val) in dic {
            let modKey = "\(addedKey) {\(key)}"
            if let val = val as? [String: Any] {
                flattenDic(val, out: &out, level: level - 1, addedKey: modKey)
            } else {
                // overwrite if key exists, but very rare case
                var value = String()
                if let val = val as? Array<Any> {
                    value = "\(val)".filter { !" \n".contains($0) }
                    out[modKey] = value
                } else {
                    out[modKey] = val
                }
                
            }
        }
    }
    flattenDic(dic, out: &result, level: keepLevel)
    return result
}

func dict<K, V>(_ tuples: [(K, V)]) -> [K: V] {
    return tuples.reduce([:]) {
        var dict: [K: V] = $0
        dict[$1.0] = $1.1
        return dict
    }
}
