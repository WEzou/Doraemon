//
//  ImageCell.swift
//  CircleImageView
//
//  Created by oncezou on 2018/12/7.
//  Copyright © 2018年 oncezw. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {

    let imageview = UIImageView()
    let imageview2 = UIImageView()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        imageview.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.contentView.addSubview(imageview)
        
        imageview2.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.contentView.addSubview(imageview2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let center = self.contentView.center
        imageview.center = CGPoint(x: center.x - 20, y: center.y)
        imageview2.center = CGPoint(x: center.x + 40, y: center.y)
    }
    
    func setCircleImage(_ imageName: String,_ type: CornerRadiusType) {
        switch type {
        case .radius:
            let image = UIImage(named: imageName)
            imageview.image = image
            imageview.radiusToCircle()
            imageview2.image = image
            imageview2.radiusToCircle()
        case .rasterize:
            let image = UIImage(named: imageName)
            imageview.image = image
            imageview.rasterizeToCircle()
            imageview2.image = image
            imageview2.rasterizeToCircle()
        case .mask:
            let image = UIImage(named: imageName)
            imageview.image = image
            imageview.maskToCircle()
            imageview2.image = image
            imageview2.maskToCircle()
        case .draw:
            imageview.drawToCircle(imageName)
            imageview2.drawToCircle(imageName)
        case .bitmap:           
            imageview.bitmapToCircle(imageName)
            imageview2.bitmapToCircle(imageName)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
