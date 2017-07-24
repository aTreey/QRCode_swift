//
//  SystemPermissions.swift
//  QRCode_swift
//
//  Created by Hongpeng Yu on 2017/7/5.
//  Copyright © 2017年 Hongpeng Yu. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary

class SystemPermissions: NSObject {
    
    /// 相机权限
    static func camerPermissions() -> Bool {
        
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus != AVAuthorizationStatus.denied {
            return true
        } else {
            return false
        }
    }
    
    /// 相册权限
    static func photoAlbumPersmissions() -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus != PHAuthorizationStatus.denied {
            return true
        } else {
            return false
        }
    }
}
