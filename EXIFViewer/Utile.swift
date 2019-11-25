//
//  Utile.swift
//  EXIF Viewer
//
//  Created by LeonKang on 2019/11/9.
//  Copyright © 2019 LeonKang. All rights reserved.
//

import Foundation
import UIKit

public let kScreenHeight = UIScreen.main.bounds.height
public let kScreenWidth = UIScreen.main.bounds.width

extension UIStoryboard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
    
    static func viewController(_ storyboard: UIStoryboard, identifier: String) -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}

extension Dictionary {
    subscript(i: Int) -> (key:Key, value:Value)? {
        get {
            if i <= self.count {
                let result = self[index(startIndex, offsetBy: i)]
                return result
            }
            return nil
        }
    }
}