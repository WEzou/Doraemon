//
//  HandlerImageCtl.swift
//  CircleImageView
//
//  Created by oncezou on 2018/12/8.
//  Copyright © 2018年 oncezw. All rights reserved.
//

import UIKit

class HandlerImageCtl: UIViewController {

    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(userDidTakeScreenshot), name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
        view.backgroundColor = UIColor.white
        let maskImage = UIImageView(frame: self.view.bounds)
        maskImage.image = image?.addWatermark(text: "oncezou",imageName: "bicycle")
        view.addSubview(maskImage)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // @objc 是swift能使用oc的动态性
    @objc func userDidTakeScreenshot() {
        print("使用系统的截屏")
    }
    
    deinit {
        ///移除通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
    }
}
