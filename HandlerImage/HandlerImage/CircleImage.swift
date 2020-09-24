//
//  CircleImage.swift
//  CircleImageView
//
//  Created by oncezou on 2018/12/7.
//  Copyright © 2018年 oncezw. All rights reserved.
//

import Foundation
import UIKit

enum CornerRadiusType {
    case radius
    case rasterize
    case mask
    case draw
    case bitmap
}

// 添加路径
private func addRoundedRectToPath(context: CGContext,rect: CGRect,ovalWidth: CGFloat,ovalHeight: CGFloat) {
    var fw: CGFloat = 0
    var fh: CGFloat = 0
    
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        context.addRect(rect)
        return
    }
    
    context.saveGState()
    context.translateBy(x: rect.minX, y: rect.minY)
    context.scaleBy(x: ovalWidth, y: ovalHeight)
    fw = rect.width / ovalWidth
    fh = rect.height / ovalHeight
    
    context.move(to: CGPoint(x: fw, y: fh/2))
    // Top right corner
    context.addArc(tangent1End: CGPoint(x: fw, y: fh), tangent2End: CGPoint(x: fw/2, y: fh), radius: 1)
    // Top left corner
    context.addArc(tangent1End: CGPoint(x: 0, y: fh), tangent2End: CGPoint(x: 0, y: fh/2), radius: 1)
    // Lower left corner
    context.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: fw/2, y: 0), radius: 1)
    // Back to lower right
    context.addArc(tangent1End: CGPoint(x: fw, y: 0), tangent2End: CGPoint(x: fw, y: fh/2), radius: 1)

    context.closePath()
    context.restoreGState()
}

extension UIImageView {
    
    // 获取宽高中的最小值
    func minHW() -> CGFloat {
        return min(self.bounds.size.width, self.bounds.size.height)
    }
    
    // 判断是否设置尺寸
    func isSquare() -> Bool {
        let size = self.bounds.size
        guard size.width>0 && size.height>0 else {
            print("The size of the imageview cannot be empty")
            return false
        }
        return true
    }
    
    // cornerRadius + masksToBounds 设置圆角
    // 比较消耗性能
    func radiusToCircle(_ radiusm: CGFloat = 0) {
        guard isSquare() else {
            return
        }
        let radius = radiusm > 0 ? radiusm : minHW()/2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    // cornerRadius + shouldRasterize 设置圆角
    // 虽然光栅化会造成离屏渲染，但是可以使离屏渲染的结果缓存到内存中存为位图，使用的时候直接使用缓存，节省了一直离屏渲染损耗的性能。
    func rasterizeToCircle(_ radiusm: CGFloat = 0) {
        guard isSquare() else {
            return
        }
        let radius = radiusm > 0 ? radiusm : minHW()/2
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    // UIBezierPath + CAShapeLayer 设置圆角
    // mask会造成离屏渲染，性能最差XXXXXX
    func maskToCircle(_ radiusm: CGFloat = 0) {
        guard isSquare() else {
            return
        }
        let size = (radiusm > 0) ? CGSize(width: radiusm, height: radiusm) : self.bounds.size
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: size)
        let shape = CAShapeLayer()
        shape.frame = self.bounds
        shape.path = path.cgPath
        self.layer.mask = shape
    }
    
    // 开启上下文Context 设置圆角
    // 虽然不会造成离屏渲染，但是通过draw，消耗CPU
    func drawToCircle(_ imageName: String,_ radiusm: CGFloat = 0) {
        guard isSquare() else {
            return
        }
        let radius = radiusm > 0 ? radiusm : minHW()
        var image = UIImage(named: imageName)
        let opaque = true
        /** opaque: true（不透明） false（透明）
         *  设置为false在图层渲染性能方面并不是很好
         *  设置为true，圆角会被裁切掉，但是由于是不透明的模式，所以看不到下面的颜色，默认看到了黑色的背景。
         *  可以填充颜色:
         *      UIColor.white.setFill()
         *      UIRectFill(self.bounds)
         */
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, UIScreen.main.scale)
        if opaque
        {
            UIColor.white.setFill()
            UIRectFill(self.bounds)
        }
        UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).addClip()
        image?.draw(in: self.bounds)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = image
    }
    
    // 个人认为和drawToCircle类似，drawToCircle是开启图片上下文，bitmapToCircle时开启位图上下文，再将图片绘制进去
    func bitmapToCircle(_ imageName: String,_ radiusm: CGFloat = 0) {
        
        let bsize = self.bounds.size
        let size = CGSize(width: bsize.width*2, height: bsize.height*2)
        let radius = radiusm > 0 ? radiusm*2 : minHW()
        
        var image = UIImage(named: imageName)
        guard image != nil else {
            return
        }
        // 创建一个色域(color space)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // 创建位图上下文(Context Reference)
        // 每个通道的位数是 8 bit （BPC）
        // 4 byte ARGB 值
        guard let context = CGContext(data: nil, width: Int(size.width),
                                      height: Int(size.height), bitsPerComponent: 8,
                                      bytesPerRow: Int(size.width * 4), space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            else { return }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        context.beginPath()
        // 绘制路径
        addRoundedRectToPath(context: context, rect: rect, ovalWidth: radius, ovalHeight: radius)
        context.closePath()
        context.clip()
        context.draw(image!.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let imageMasked = context.makeImage()
        image = UIImage(cgImage: imageMasked!)
        self.image = image
    }
    
    /**
     * 前3种都是对UIImageView的layer进行处理，所以无法应用到UIButton上,也可给UIButton添加类似的分类
     * 第4/5种是对UIImage进行draw，可以应用在UIButton
     */
    
    /** 模拟器 Simulator->debug->  真机 Xcode->debug->View Debugging->Rendering
     *  Color off-screen Rendered(检测离屏渲染) 如果会发生离屏渲染会呈现黄色 (第2和第3种方法会造成离屏渲染)
     *  Color Blended Layers(混合图层->检测图像的混合模式) 绿->红 （注：这和图片本身也有关系）
     */
    
    /** 性能的查看可以通过列表的形式观察帧数
     *  工具： Xcode->Open Developer Tool->Instruments->Core Animation
     *  通过每秒的帧数来对比性能，屏幕的刷新默认是60/s，所以如果能保持在55/s左右，那么是最好的
     */
    
}

