//
//  ExifInfoViewController.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/9/24.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import UIKit
import Photos
import MBProgressHUD
import CoreLocation
import MapKit

public let kInfoViewControllerIdentifier = "kInfoViewControllerIdentifier"

class ExifInfoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    lazy var metaDataManager: MetaDataManager = MetaDataManager(asset: asset)
    var dataSource = [String: Any]()
    var metaData: MetaData?
    
    public var image: UIImage? {
        didSet {
            updateUI()
        }
    }
    
    public var asset: PHAsset! {
        didSet {
            AssetManager.resolveAsset(asset, size: targetSize, completion: { [weak self] (image) in
                self?.image = image
            })
            self.getFullSizeAsset(asset: asset)
        }
    }
    var assetCollection: PHAssetCollection!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var imageRequestId: PHImageRequestID?
    fileprivate var editingInputRequestId: PHContentEditingInputRequestID?
    
    let tableViewHeader = UIView()
    lazy var headerSize: CGSize = {
        let height = kScreenWidth * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)
        let width = kScreenWidth
        return CGSize(width: width, height: height)
    }()
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale,
                      height: imageView.bounds.height * scale)
    }
    
    private let imagePicker: UIImagePickerController = UIImagePickerController()
    
    fileprivate let mapFrame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 156)
    
    let mapViewHeader = UIView()
    private lazy var mapView: MKMapView = {
        let map = MKMapView(frame: mapFrame)
        map.delegate = self
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PHPhotoLibrary.shared().register(self)
    }
    
    func updateUI() {
        self.imageView.image = image
        self.tableView.reloadData()
    }
    
    func updateMapView() {
        if let coordinate = self.metaData?.location?.coordinate {
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            mapView.setRegion(region, animated: true)
            
            let restaurantAnnotation = MKPointAnnotation()
            restaurantAnnotation.coordinate = coordinate;
//            restaurantAnnotation.title = "address";
            mapView.addAnnotation(restaurantAnnotation)
            
            let circle = MKCircle(center: coordinate, radius: 30)
            mapView.addOverlay(circle)
        }
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
        MBProgressHUD.showAdded(to: view, animated: true)
        metaDataManager.getOrientationMetaData { result in
            let data = MetaData(result)
            self.metaData = data
            self.dataSource = data.metaDataDictionary
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tableView.reloadData()
            }
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
            self.tableView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ExifInfoViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let result = dataSource[section]?.value as? Dictionary<String, Any> {
            count = result.keys.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "kCellIdentifier") as? InfoTableViewCell
        if cell == nil {
            cell = InfoTableViewCell(style: .default, reuseIdentifier: "kCellIdentifier")
        }
        let section = indexPath.section
        if section < dataSource.count {
            let values = dataSource[section]
            var key = values?.key
            var value = values?.value
            if let result = value as? Dictionary<String, Any> {
                let keys = Array(result.keys)
                key = keys[indexPath.row]
                value = result[key ?? ""]
            }

            cell?.titleLabel.text = key ?? ""
            cell?.titleLabel.sizeToFit()
            
            cell?.valueLabel.text = "\(value ?? "")"
            cell?.valueLabel.numberOfLines = 0
            cell?.valueLabel.sizeToFit()
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard tableViewHeader.subviews.contains(imageView) else {
                tableViewHeader.addSubview(imageView)
                tableViewHeader.frame = CGRect(origin: CGPoint.zero, size: headerSize)
                imageView.frame = CGRect(origin: CGPoint.zero, size: headerSize)
                return tableViewHeader
            }

            return tableViewHeader
        } else if section == 1 {
            guard mapViewHeader.subviews.contains(mapView) else {
                mapViewHeader.addSubview(mapView)
                mapViewHeader.frame = mapFrame
                updateMapView()
                return mapViewHeader
            }
            DispatchQueue.main.async {
                self.updateMapView()
            }
            return mapViewHeader
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section]?.key
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = CGFloat.zero
        if section == 0 {
            height = headerSize.height
        } else if section == 1 {
            height = mapFrame.height
        }
        return height
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


// MARK: PHPhotoLibraryChangeObserver
extension ExifInfoViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let curAsset = asset, let details = changeInstance.changeDetails(for: curAsset) else {
            return
        }
        asset = details.objectAfterChanges
        
        DispatchQueue.main.async {
            guard let _ = self.asset else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            if details.assetContentChanged {
                self.updateUI()
            }
        }
    }
}

extension ExifInfoViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let annaotationId = "annaotationId"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annaotationId)
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annaotationId)
//        }
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
//        button.layer.cornerRadius = 5
//        button.backgroundColor = UIColor.blue
//        annotationView?.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
//        annotationView?.layer.cornerRadius = 7.5
//        annotationView?.canShowCallout = true
//        return annotationView
//    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
}
