//
//  ViewController.swift
//  QRCode_swift
//
//  Created by Hongpeng Yu on 2017/7/4.
//  Copyright © 2017年 Hongpeng Yu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WZQRCodeControllerDelegate {
    
    var testButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

    }
    
    
    private func setupViews() {
        testButton = UIButton(type: .custom)
        testButton?.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
        testButton?.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        testButton?.setTitle("扫描二维码", for: .normal)
        testButton?.setTitleColor(.black, for: .normal)
        testButton?.backgroundColor = UIColor.blue
        view.addSubview(testButton!)
        testButton?.addTarget(self, action: #selector(testButtonAction), for: .touchUpInside)
    }
    
    @objc private func testButtonAction() {
        let vc = WZQRCodeController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    /// 扫码控制器代理方法
    func qrController(_ QRcodeControlle: WZQRCodeController, scanFinishWithInfo info: String?) {
//        present(WZQRCodeController(), animated: true) {
//            UserDefaults.standard.set(info, forKey: "QR")
//            UserDefaults.standard.synchronize()
//            print("modal success")
//        }
    }
    
}



