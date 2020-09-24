# HandlerImage
1.	UIImageView的5种圆角处理方式
2. UIView的截图
3. UIImage添加加水印

## UIImageView的圆角处理方式
1. cornerRadius + masksToBounds
2. cornerRadius + shouldRasterize
3. UIBezierPath + CAShapeLayer(性能最差)
4. UIGraphicsBeginImageContextWithOptions
5. CGContext	(4/5可能最好的)

### 相关性
	
* 前3种都是对UIImageView的layer进行处理，所以无法应用到UIButton上,也可给UIButton添加类似的分类
    
* 第4/5种是对UIImage进行draw，可以应用在UIButton

```  
 // 模拟器 Simulator->debug->  真机 Xcode->debug->View Debugging->Rendering
 Color off-screen Rendered(检测离屏渲染) 如果会发生离屏渲染会呈现黄色 (第2和第3种方法会造成离屏渲染)
 Color Blended Layers(混合图层->检测图像的混合模式) 绿->红 （注：这和图片本身也有关系）
    
 // 性能的查看可以通过列表的形式观察帧数
 工具： Xcode->Open Developer Tool->Instruments->Core Animation
 通过每秒的帧数来对比性能，屏幕的刷新默认是60/s，所以如果能保持在55/s左右，那么是最好的
```
    
## UIView的截图
```
let image = self.view.screenshot()
``` 
### 相关性

 * UIImageJPEGRepresentation(image, 1)
 
 		将图片压缩成jpeg格式，可以通过系数来控制图片质量，0.7～1能保证比较高的质量
 
 
 * UIImagePNGRepresentation(image)
 				
 	    将图片压缩成png格式
 
 * **UIImagePNGRepresentation比UIImageJPEGRepresentation压缩的图片都大很多**

## UIImage添加加水印
```
let image = UIImage(named: imageName)
let waterImage = image.addWatermark(text: "oncezou",imageName: "bicycle")
``` 
#### 相关性

* UIGraphicsBeginImageContext(size) == UIGraphicsBeginImageContextWithOptions(size,false,1.0)

 	```
 	注: This function is equivalent to calling the UIGraphicsBeginImageContextWithOptions function with the opaque parameter set to NO and a scale factor of 1.0.
 	```
 
* **opaque**
	*  	如果知道位图是不透明的设置为true，设置为false意味位图包含一个透明通道去处理部分透明的像素
	
	```
	注: A Boolean flag indicating whether the bitmap is opaque. If you know the bitmap is fully opaque, specify YES to ignore the alpha channel and optimize the bitmap’s storage. Specifying NO means that the bitmap must include an alpha channel to handle any partially transparent pixels.
	```

* **scale**	

	*  缩放系数 0.0 == UIScreen.main.scale

	``` 
	注: The scale factor to apply to the bitmap. If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
	```
