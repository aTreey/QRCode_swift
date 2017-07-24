
//
//  QRCodeReader.swift
//  QRCode_swift
//
//  Created by Hongpeng Yu on 2017/7/4.
//  Copyright © 2017年 Hongpeng Yu. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeReader: NSObject {
    
    let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    let frontDevice: AVCaptureDevice = {
        if #available(iOS 10, *) {
            return AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        } else {
            return AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        }
    }()
    
    let session = AVCaptureSession()
    var output = AVCaptureMetadataOutput()
    var input: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var results: [String] = []
    
    var successClosure: ([String]) -> Void
    
    
    init(preview: UIView, captureDevicePosition: AVCaptureDevicePosition, success: @escaping (([String]) -> Void)) {
        do {
            try input = AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print("AVCaptureDeviceInput(): \(error)")
        }
        successClosure = success
        super.init()
        
        session.sessionPreset = UIScreen.main.bounds.height > 500 ? AVCaptureSessionPreset640x480 : AVCaptureSessionPresetHigh
        output.setMetadataObjectsDelegate(self as AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
        
        if session.canAddInput(input) && session.canAddOutput(output) {
            session.addInput(input)
            session.addOutput(output)
        }
        
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.frame = UIScreen.main.bounds
        preview.layer.insertSublayer(previewLayer!, at: 0)
        
        session.startRunning()
    }
    
    
    /// 设置扫面区域
    func setupScanningArea(view: UIView) {
        let windSize = UIScreen.main.bounds
        let scanSize = CGSize(width: windSize.width * 3 / 4, height: windSize.width * 3 / 4)
        var scaneRect = CGRect(x: (windSize.width - scanSize.width) / 2, y: (windSize.height - scanSize.height) / 2, width: scanSize.width, height: scanSize.height)
        scaneRect = CGRect(x: scaneRect.origin.y / windSize.height, y: scaneRect.origin.x / windSize.width, width: scaneRect.size.height / windSize.height, height: scaneRect.size.width / windSize.width)
        
        output.rectOfInterest = scaneRect
        
        let scanView = UIView()
        scanView.frame = CGRect(x: 0, y: 0, width: scanSize.width, height: scanSize.height)
        scanView.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        view.addSubview(scanView)
        scanView.layer.borderColor = UIColor.green.cgColor
        scanView.layer.borderWidth = 1
    }
    
    
    func recognizeQRCodeImage(image: UIImage) -> String {
        let context = CIContext(options: nil)
        let optionsDict = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: optionsDict)
        let ciimage = CIImage(image: image)
        let results = detector?.features(in: ciimage!)
        if (results?.count)! > 0 {
            let feature = results?.last as? CIQRCodeFeature
            return (feature?.messageString)!
        } else {
            return "无"
        }
    }
    
    
    /// 开启相机
    func start() {
        if !session.isRunning {
            session.startRunning()
        }
    }
}


// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeReader: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count == 0 {
            return
        }
        
        if metadataObjects.count > 0 {
            session.stopRunning()
            
            for metadataObje: Any in metadataObjects {
                if (metadataObje as AnyObject).isKind(of: AVMetadataMachineReadableCodeObject.self) {
                    let result = metadataObjects.last as! AVMetadataMachineReadableCodeObject
                    results.append(result.stringValue)
                    successClosure(results)
                } else {
                    print("扫描结果不是二维码类型: \(metadataObje.self)")
                    successClosure([])
                }
            }
        }
    }
}

