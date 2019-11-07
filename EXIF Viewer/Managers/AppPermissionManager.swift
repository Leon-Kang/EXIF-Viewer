//
//  AppPermissionManager.swift
//  RefrigeratorList
//
//  Created by LeonKang on 2019/9/14.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

enum PermissionType {
    case camera, photoLib
}

class AppPermissionManager: NSObject {
    static let shared = AppPermissionManager()
    
    public func checkCamera(_ handler: @escaping (Bool) -> Void) {
        checkPermission(type: .camera) { (result) in
            handler(result)
        }
    }
    
    public func checkPhotoLib(_ handler: @escaping (Bool) -> Void) {
        checkPermission(type: .photoLib) { (result) in
            handler(result)
        }
    }
    
    private func checkPermission(type: PermissionType, handler: @escaping (Bool) -> Void) {
        switch type {
        case .camera:
            checkCameraPermission { (success) in
                handler(success)
            }
        case .photoLib:
            return checkPhotoLibraryPermission { (result) in
                handler(result)
            }
        }
    }
    
    private func checkPhotoLibraryPermission(_ handler: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        var result = true
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                handler(status == .authorized)
            }
            return
        case .denied, .restricted:
            showRequestAlert(type: .photoLib)
            result = false
        case .authorized:
            break
        @unknown default:
            fatalError("unknown permission")
        }
        
        if UIImagePickerController.availableMediaTypes(for: .photoLibrary) == nil {
            result = false
        }
        handler(result)
    }
    
    private func checkCameraPermission(_ handler: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        var result = true
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (success) in
                handler(success)
            }
            return
        case .denied, .restricted:
            showRequestAlert(type: .camera)
            result = false
        case .authorized:
            break
        @unknown default:
            fatalError("unknown permission")
        }
        
        if UIImagePickerController.availableMediaTypes(for: .camera) == nil {
            result = false
        }
        
        handler(result)
    }
    
    private func showRequestAlert(type: PermissionType) {
        var message = ""
        switch type {
        case .camera:
            message = "pls allow we open the camera"
        case .photoLib:
            message = "pls allow we open get pic from photo library"
        }
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let root: UIViewController = UIApplication.shared.windows.first?.rootViewController {
            root.present(alert, animated: true)
        }
    }
    
}
