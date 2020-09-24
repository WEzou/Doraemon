//
//  ViewController.swift
//  CircleImageView
//
//  Created by oncezou on 2018/12/7.
//  Copyright © 2018年 oncezw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let imageviewShot = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creatImageview(30).radiusToCircle()
        creatImageview(160).rasterizeToCircle()
        creatImageview(290).maskToCircle()
        creatImageview(420,true).drawToCircle("dog")
        creatImageview(550,true).bitmapToCircle("dog")
        
        creatButton(190, "NEXT", #selector(click))
        creatButton(450, "SHOT", #selector(shot))
    }
    
    @objc func click() {
        let circleCtl = CircleTableCtl()
        self.present(circleCtl, animated: true, completion: nil)
    }
    
    @objc func shot() {
        let handlerCtl = HandlerImageCtl()
        handlerCtl.image = view.screenshot()
        self.present(handlerCtl, animated: true, completion: nil)
    }
    
    func creatImageview(_ y: CGFloat,_ flag: Bool = false) -> UIImageView {
        let size = CGSize(width: 100, height: 100)
        let origin = CGPoint(x: view.center.x-50, y: y)
        let imageview = UIImageView(frame: CGRect(origin: origin, size: size))
        if !false
        {
            imageview.image = UIImage(named: "dog")
        }
        view.addSubview(imageview)
        return imageview
    }
    
    func creatButton(_ y: CGFloat,_ title: String,_ action: Selector) {
        let button = UIButton(frame: CGRect(x: 20, y: y, width: 100, height: 40))
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.orange, for: .normal)
        view.addSubview(button)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

