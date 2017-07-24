//
//  QRCoderReaderView.swift
//  QRCode_swift
//
//  Created by Hongpeng Yu on 2017/7/5.
//  Copyright © 2017年 Hongpeng Yu. All rights reserved.
//

import UIKit

public protocol QRCoderReaderViewDelegate {
    
    func openPhotoAlbumButtonAction()
}

class QRCoderReaderView: UIView {

    var delegate: QRCoderReaderViewDelegate?
    
    var coderReader: QRCodeReader?
    var photoAlbumButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupButtonsView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupUI() {
        if !SystemPermissions.camerPermissions() {
            alert(title: "相机权限", message: "前往设置中开启相机权限", buttonTitle: "好")
            return
        }
        coderReader = QRCodeReader(preview: self, captureDevicePosition: .back) { (results) in
            
            self.alert(title: "扫描结果", message: results.last!, buttonTitle: "OK")
        }
        coderReader?.setupScanningArea(view: self)
    }
    
    
    private func setupButtonsView() {
        let buttonsView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 100, width: UIScreen.main.bounds.width, height: 100))
        self.addSubview(buttonsView)
        flashlightButton.center = CGPoint(x: buttonsView.bounds.midX - 40, y: buttonsView.bounds.midY)
        
        
        photoAlbumButton = UIButton(type: .custom)
        photoAlbumButton?.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        photoAlbumButton?.center = CGPoint(x: buttonsView.bounds.midX + 40, y: buttonsView.bounds.midY)
        photoAlbumButton?.layer.cornerRadius = 30
        photoAlbumButton?.layer.masksToBounds = true
        photoAlbumButton?.setTitle("相册", for: .normal)
        photoAlbumButton?.backgroundColor = UIColor.blue
        photoAlbumButton?.addTarget(self, action: #selector(openPhotoAlbumButtonAction(controller:)), for: .touchUpInside)
        
        buttonsView.addSubview(photoAlbumButton!)
        buttonsView.addSubview(flashlightButton)
    }
    
    func flashlightButtonAction() {

    }
    
    
    func openPhotoAlbumButtonAction(controller: UIViewController) {
        print("相册")
        if ((delegate?.openPhotoAlbumButtonAction()) != nil) {
            delegate?.openPhotoAlbumButtonAction()
        }
    }
    
    fileprivate func alert(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (okAction) in
            self.coderReader?.start()
        }
        alert.addAction(action)
        let rootVc = UIApplication.shared.keyWindow?.rootViewController
        rootVc?.present(alert, animated: true, completion: nil)
    }
    
    private lazy var flashlightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.setTitle("灯光", for: .normal)
        button.setTitleColor(.yellow, for: .highlighted)
        button.addTarget(self, action: #selector(flashlightButtonAction), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        return button
    }()
    
}
