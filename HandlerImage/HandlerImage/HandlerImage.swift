//
//  HandlerImage.swift
//  CircleImageView
//
//  Created by oncezou on 2018/12/8.
//  Copyright © 2018年 oncezw. All rights reserved.
//

import Foundation
import UIKit

enum ImageFormatType {
    case none
    case png
    case jpeg
}

// 保存截图的图片到本地
private func saveImage(_ image: UIImage?,_ type: ImageFormatType = .png) {
    guard image != nil else {
        print("image is empty")
        return
    }
    var data: Data?
    var suffix = ""
    //把图片转成二进制流
    switch type {
    case .png:
        suffix = "png"
        data = UIImagePNGRepresentation(image!)
    case .jpeg:
        suffix = "jpeg"
        data = UIImageJPEGRepresentation(image!, 1)
    default:
        break
    }
    guard data != nil else {
        print("data is nil")
        return
    }
    
    let filePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first?.appending("/Screenshot")
    if !FileManager.default.fileExists(atPath: filePath!) {
        try? FileManager.default.createDirectory(atPath: filePath!, withIntermediateDirectories: true, attributes: nil)
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYYMMddHHmmss"
    let dateString = dateFormatter.string(from: Date())
    let imagePath = filePath!.appending("/\(dateString).\(suffix)")
    let url = URL(fileURLWithPath: imagePath, isDirectory: false)
    do {
        try data!.write(to: url)
    }catch {
        print("save image fail: \(error)")
    }
}

/**
 * UIImageJPEGRepresentation(image, 1)
 *      将图片压缩成jpeg格式，可以通过系数来控制图片质量，0.7～1能保证比较高的质量
 *
 * UIImagePNGRepresentation(image)
 *      将图片压缩成png格式
 *
 * UIImagePNGRepresentation比UIImageJPEGRepresentation压缩的图片都大很多
 */

// MARK: 截图 - UIView
extension UIView {
    
    // 截图
    func screenshot() -> UIImage {
        //1.开启一个位图上下文
//        UIGraphicsBeginImageContext(self.bounds.size)
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
        //2.把View的内容绘制到上下文当中
        let ctx =  UIGraphicsGetCurrentContext()
        //UIView内容想要绘制到上下文当中, 必须使用渲染的方式
        self.layer.render(in: ctx!)
        //3.从上下文当中生成一张图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //4.关闭上下文
        UIGraphicsEndImageContext()
        saveImage(newImage)
        return newImage!
    }
}

// MARK: 图片加水印 - UIImage
extension UIImage {
    
    /** 图片加水印
     *  - Parameters:
     *      - text: 水印完整文字
     *      - textColor: 文字颜色
     *      - textFont: 文字大小
     *      - imageName: 前缀图片(如果是nil可以不传)
     *      - suffixText: 尾缀文字(如果是nil可以不传)
     *      - suffixFont: 尾缀文字大小(如果是nil可以不传)
     *      - suffixColor: 尾缀文字颜色(如果是nil可以不传)
     *  - Returns: 水印图片
     */
     func addWatermark(text: String,
                       textColor: UIColor = UIColor.black,
                       textFont: UIFont = UIFont.systemFont(ofSize: 14),
                       imageName: String? = nil,
                       suffixText: String? = nil,
                       suffixFont: UIFont? = nil,
                       suffixColor: UIColor? = nil) -> UIImage {
        // 开启和原图一样大小的上下文（保证图片不模糊的方法）
        /*
         * size:   指定将来创建出来的bitmap的大小
         * opaque: 设置不透明 true不透明，false透明
         * scale:  代表缩放 0.0 == UIScreen.main.scale
         * 注： 如果频繁使用加水印，并设置scale = 0.0，可能会导致内存崩溃，所以要选择取舍
         */
        UIGraphicsBeginImageContextWithOptions(self.size, true, self.scale)
        
        // 图形重绘
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        var suffixAttr: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor:textColor, NSAttributedStringKey.font:textFont]
        let attrS = NSMutableAttributedString(string: text, attributes: suffixAttr)
        
        // 添加后缀的属性字符串
        if let suffixStr = suffixText {
            let range = NSRange(location: text.count - suffixStr.count, length: suffixStr.count)
            if suffixFont != nil {
                suffixAttr[NSAttributedStringKey.font] = suffixFont
            }
            
            if suffixColor != nil {
                suffixAttr[NSAttributedStringKey.foregroundColor] = suffixColor
            }
            attrS.addAttributes(suffixAttr, range: range)
        }
        
        let bottom: CGFloat = 20    // 与底部的间距
        let margin: CGFloat = imageName==nil ? 0 : 10  // 图片与文字的间距
        
        // 文字属性
        let size =  attrS.size()
        let x = (self.size.width - size.width + margin) / 2
        let y = self.size.height - size.height - bottom
        
        // 绘制文字
        attrS.draw(in: CGRect(x: x, y: y, width: size.width, height: size.height))
        
        if imageName != nil {
            // 图片属性
            let preImage = UIImage(named: imageName!)
            let xm = x - size.height - margin
            let ym = y + 1
            preImage?.draw(in: CGRect(x: xm, y: ym, width: size.height, height: size.height))
        }
        
        // 从当前上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        
        return image!
    }
}

/** UIGraphicsBeginImageContextWithOptions 与 UIGraphicsBeginImageContext
 *
 * UIGraphicsBeginImageContext(size) == UIGraphicsBeginImageContextWithOptions(size,false,1.0)
 
 *  注: This function is equivalent to calling the UIGraphicsBeginImageContextWithOptions function with the opaque parameter set to NO and a scale factor of 1.0.
 *
 *
 *  opaque(如果知道位图是不透明的设置为true，设置为false意味位图包含一个透明通道去处理部分透明的像素)
 
    注:  A Boolean flag indicating whether the bitmap is opaque. If you know the bitmap is fully opaque, specify YES to ignore the alpha channel and optimize the bitmap’s storage. Specifying NO means that the bitmap must include an alpha channel to handle any partially transparent pixels.
 *
 *  scale(缩放系数) 0.0 == UIScreen.main.scale
 
     注:  The scale factor to apply to the bitmap. If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
 *
 */

