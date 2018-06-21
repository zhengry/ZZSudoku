//
//  EditCell.swift
//  ShuDuDemo
//
//  Created by zry on 2018/6/4.
//  Copyright © 2018年 zry. All rights reserved.
//

import UIKit



class EditCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    public var row = 0
    public var column = 0
    public var index = 0
    public var zone = (0,0)
    public var zoneIndex = 0
    public var title: Int = 0
    public var editable = true
    public var isTrue = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 0.5
        self.layer.borderColor = self.color(WithHex: 0x4682B4).cgColor
        // Initialization code
    }
    
    func color(WithHex hex: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(hex & 0xFF))/255.0, alpha: 1.0)
        
    }
    

}
