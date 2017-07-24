//
//  WZQRCodeController.swift
//  QRCode_swift
//
//  Created by Hongpeng Yu on 2017/7/6.
//  Copyright © 2017年 Hongpeng Yu. All rights reserved.
//

import UIKit
import AVFoundation


@objc(WZQRCodeControllerDelegate)
protocol WZQRCodeControllerDelegate {
    func qrController(_ QRcodeControlle: WZQRCodeController, scanFinishWithInfo info: String?)
}

class WZQRCodeController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var delegate: WZQRCodeControllerDelegate?
    var result: String?
    
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
    var isOpenFlash: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupAVCapture ()
        view.addSubview(scanView)
        view.addSubview(line)
        setupButtonsView()
        start()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(dismissQRController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(photoAlbumButtonAction))
        setScanBundary()
    }
    
    @objc private func dismissQRController() {
//        dismiss(animated: true) { 
//            // 消失
//        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupAVCapture() {
        do {
            try input = AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print("AVCaptureDeviceInput(): \(error)")
        }
        
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
        
        view.layer.insertSublayer(previewLayer!, at: 0)
    }
    
    private func isAvailabelFlash() -> Bool {
        if device != nil && (device?.hasFlash)! && (device?.hasTorch)! {
            return true
        }
        return false
    }
    
    private func setFlash() {
        if isAvailabelFlash() {
            do {
                try input?.device.lockForConfiguration()
                var isOpen = false
                if input?.device.torchMode == AVCaptureTorchMode.on {
                    isOpen = false
                } else if input?.device.torchMode == AVCaptureTorchMode.off {
                    isOpen = true
                }
                input?.device.torchMode = isOpen ? AVCaptureTorchMode.on : AVCaptureTorchMode.off
                input?.device.unlockForConfiguration()
            } catch let error {
                print("error = \(error)")
            }
        }
    }
    
    /// 二维码图片识别
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
            return ""
        }
    }
    
    /// 开启相机
    func start() {
        line.frame = CGRect(x: self.scanView.frame.origin.x, y: self.scanView.frame.origin.y, width: self.scanView.frame.size.width, height: 5)
        UIView.animateKeyframes(withDuration: 3.0, delay: 0.0, options: .repeat, animations: {
            self.line.frame = CGRect(x: self.scanView.frame.origin.x, y: self.scanView.frame.origin.y + self.scanView.frame.size.height - 5, width: self.scanView.frame.size.width, height: 5)
        }, completion: nil)
        
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stop() {
        line.layer.removeAllAnimations()
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(1007);
        //震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    
    func setScanBundary() {
        
        
        let top_Layer = CALayer()
        top_Layer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: scanView.frame.minY)
        top_Layer.backgroundColor = UIColor.black.withAlphaComponent(0.4).cgColor
        previewLayer?.addSublayer(top_Layer)

        let lef_layer = CALayer()
        lef_layer.frame = CGRect(x: 0, y: top_Layer.frame.maxY, width: scanView.frame.minX, height: scanView.frame.height)
        lef_layer.backgroundColor = UIColor.black.withAlphaComponent(0.4).cgColor
        previewLayer?.addSublayer(lef_layer)
        
 
        let bottom_layer = CALayer()
        bottom_layer.frame = CGRect(x: 0, y: scanView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - scanView.frame.maxY)
        bottom_layer.backgroundColor = UIColor.black.withAlphaComponent(0.4).cgColor
        previewLayer?.addSublayer(bottom_layer)
        
        let right_layer = CALayer()
        right_layer.frame = CGRect(x: scanView.frame.maxX, y: scanView.frame.minY, width: UIScreen.main.bounds.width - scanView.frame.maxX, height: scanView.frame.height)
        right_layer.backgroundColor = UIColor.black.withAlphaComponent(0.4).cgColor
        previewLayer?.addSublayer(right_layer)
    }
    
    private func setupButtonsView() {
        let buttonsView = UIView(frame: CGRect(x: 0, y: scanView.frame.maxY, width: UIScreen.main.bounds.width, height: 100))
        view.addSubview(buttonsView)
        flashlightButton.center = CGPoint(x: buttonsView.bounds.midX - 40, y: buttonsView.bounds.midY)
        photoAlbumButton.center = CGPoint(x: buttonsView.bounds.midX + 40, y: buttonsView.bounds.midY)
        
        buttonsView.addSubview(photoAlbumButton)
        buttonsView.addSubview(flashlightButton)
    }
    
    
    /// 打开关闭闪光灯
    func flashlightButtonAction() {
        isOpenFlash = !isOpenFlash
        setFlash()
    }
    
    
    func photoAlbumButtonAction() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    fileprivate func alert(title: String?, message: String?, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default) { (action) in
            self.start()
//            self.navigationController?.popViewController(animated: true)
            if self.delegate != nil {
                self.delegate?.qrController(self, scanFinishWithInfo: self.result!)
            }
            
            
        }
        alert.addAction(action)
        let rootVc = UIApplication.shared.keyWindow?.rootViewController
        rootVc?.present(alert, animated: true, completion: nil)
    }
    
    
   
    
    private lazy var scanView: UIView = {
        let windSize = UIScreen.main.bounds
        let scanSize = CGSize(width: windSize.width * 3 / 4, height: windSize.width * 3 / 4)
        var scaneRect = CGRect(x: (windSize.width - scanSize.width) / 2, y: (windSize.height - scanSize.height) / 2, width: scanSize.width, height: scanSize.height)
        scaneRect = CGRect(x: scaneRect.origin.y / windSize.height, y: scaneRect.origin.x / windSize.width, width: scaneRect.size.height / windSize.height, height: scaneRect.size.width / windSize.width)
        
        self.output.rectOfInterest = scaneRect
        
        let scanView = UIView()
        scanView.frame = CGRect(x: 0, y: 0, width: scanSize.width, height: scanSize.height)
        scanView.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        scanView.layer.borderColor = UIColor.cyan.cgColor
        scanView.layer.borderWidth = 1
        return scanView
    }()
    
    
    private lazy var line: UIImageView = {
        let line = UIImageView(frame: CGRect(x: self.scanView.frame.origin.x, y: self.scanView.frame.origin.y, width: self.scanView.frame.size.width, height: 5))
        line.image = #imageLiteral(resourceName: "line")
        return line
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    private lazy var flashlightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.setTitle("灯光", for: .normal)
        button.setTitleColor(.yellow, for: .highlighted)
        button.addTarget(self, action: #selector(WZQRCodeController.flashlightButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoAlbumButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.setTitle("相册", for: .normal)
        button.setTitleColor(.yellow, for: .highlighted)
        button.addTarget(self, action: #selector(WZQRCodeController.photoAlbumButtonAction), for: .touchUpInside)
        return button
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    deinit {
        print("WZQRCodeController 销毁")

    }
}

extension WZQRCodeController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            result = recognizeQRCodeImage(image: editImage)
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            result = recognizeQRCodeImage(image: originalImage)
        }
        
        
        dismiss(animated: true) { 
            // call back
            if self.result?.characters.count == 0 {
                self.alert(title: "识别失败!", message: "", buttonTitle: "确定")
                return
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            // call back
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension WZQRCodeController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count == 0 {
            return
        }
        
        if metadataObjects.count > 0 {
            self.stop()
            playSoundEffect()
            for metadataObje: Any in metadataObjects {
                if (metadataObje as AnyObject).isKind(of: AVMetadataMachineReadableCodeObject.self) {
                    let metadataObj = metadataObjects.last as! AVMetadataMachineReadableCodeObject
                    result = metadataObj.stringValue
                    alert(title: result, message: "扫描结果", buttonTitle: "确定")
                } else {
                    print("扫描结果不是二维码类型: \(metadataObje.self)")
                }
            }
        }
    }
}
