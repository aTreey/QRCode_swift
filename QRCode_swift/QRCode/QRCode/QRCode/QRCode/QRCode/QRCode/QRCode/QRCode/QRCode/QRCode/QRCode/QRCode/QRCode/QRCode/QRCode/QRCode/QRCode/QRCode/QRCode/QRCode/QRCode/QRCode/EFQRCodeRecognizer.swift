

//
//  EFQRCodeRecognizer.swift
//  QRCode_swift
//
//  Created by Hongpeng Yu on 2017/7/6.
//  Copyright © 2017年 Hongpeng Yu. All rights reserved.
//

import UIKit
import CoreImage

class EFQRCodeRecognizer {
    
    var image: UIImage?
    
    public init(image: UIImage) {
        self.image = image
    }
    
    func UIImageToCGImage(_ image: UIImage?) -> CGImage? {
        if let uiimage = image, let ciimage = CIImage(image: uiimage) {
            return CIContext(options: nil).createCGImage(ciimage, from: ciimage.extent)
        }
        return nil
    }
    
    
    func recognizer() -> String? {
        return recognizeQRCoder()
    }
    
    
    private func recognizeQRCoder() -> String? {
        guard let ciimage = CIImage(image: image!) else { return "二维码图片错误" }
        let context = CIContext(options: [String : Any]())
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let deletor = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        guard let features = deletor?.features(in: ciimage) else { return "识别结果为空" }
        
        if let feature = features.last as? CIQRCodeFeature {
            let string = feature.messageString
            return string
        }
        return ""
    }
}
