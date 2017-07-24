//
//  WZQRCode.swift
//  QRCode_swift
//
//  Created by Hongpeng Yu on 2017/7/6.
//  Copyright © 2017年 Hongpeng Yu. All rights reserved.
//

import UIKit

public class WZQRCode {

    // MARK: 从相册识别
    func recognizeQRCodeImage(image: UIImage) -> String? {
        return EFQRCodeRecognizer(image: image).recognizer()
    }
    
//    func recognize() -> String? {
//        return 
//    }

}
