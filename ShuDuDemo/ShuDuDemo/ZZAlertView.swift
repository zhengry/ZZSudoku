//
//  ZZAlertView.swift
//  ShuDuDemo
//
//  Created by zry on 2018/6/8.
//  Copyright © 2018年 zry. All rights reserved.
//

import UIKit

class ZZAlertAction: NSObject {

    var title: String?
    var handle: () -> Void
    init(title: String?, handle: @escaping () -> Void) {
        self.title = title
        self.handle = handle
        super.init()
    }

}


class ZZAlertView: UIView {
    let MIN_WIDTH = UIScreen.main.bounds.width - 200
    let MAX_WIDTH = UIScreen.main.bounds.width - 40
    let HEIGHT: CGFloat = 120.00
    let BASIC_TAG = 100
    
    var titleWidth: CGFloat = 0.00
    var titleLabel = UILabel()
    var shadowView = UIView()
    let line = UIView()
    

    var actions = [ZZAlertAction]()
    var buttons = [UIButton]()
    
    func add(Title title: String!) {
        self.backgroundColor = UIColor.white
        self.frame = CGRect(x: 0, y: 0, width: MIN_WIDTH, height: HEIGHT)
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        shadowView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        shadowView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.width, height: 60))
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.text = title
        label.textColor = UIColor.black
        self.addSubview(label)
        titleLabel = label
        
        line.frame = CGRect(x: 0, y: titleLabel.bottom, width: self.width, height: 0.8)
        line.backgroundColor = UIColor.lightGray
        self.addSubview(line)
        
    }
    
    
    func add(Action action: ZZAlertAction) {
        actions.append(action)
        //计算title长度
        let size = action.title?.size(withAttributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)])
        titleWidth += (size?.width)!
        //计算button位置
        if titleWidth <= MIN_WIDTH {
            titleWidth = MIN_WIDTH
        }else if titleWidth >= MAX_WIDTH{
            titleWidth = MAX_WIDTH
        }
        self.width = titleWidth
        
        line.frame = CGRect(x: 0, y: titleLabel.bottom, width: self.width, height: 0.8)
        
        //添加button
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 60)
        button.setTitle(action.title, for: .normal)
        let hex = 0x4682B4
        
        let color = UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(hex & 0xFF))/255.0, alpha: 1.0)
        
        button.setTitleColor(color, for: .normal)
        button.tag = BASIC_TAG + actions.index(of: action)!
        button.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        self.addSubview(button)
        buttons.append(button)
        
        self.center = CGPoint(x: shadowView.width / 2.00, y: shadowView.height / 2.00)

        let wid = self.width / CGFloat(actions.count)
        
        for btn in buttons {
            btn.frame = CGRect(x: wid * CGFloat(buttons.index(of: btn)!), y: titleLabel.bottom, width: wid, height: 60 - line.height)
        }
        
    }
    
    func show(inView view: UIView) {
        for button in buttons {
            let index = buttons.index(of: button)
            if index! < buttons.count - 1 {
                let colLine = UIView(frame: CGRect(x: button.width - 0.8, y: 0, width: 0.8, height: button.height))
                colLine.backgroundColor = UIColor.lightGray
                button.addSubview(colLine)
            }
        }
        
        titleLabel.centerX = self.width / 2.00
        view.addSubview(shadowView)
        view.addSubview(self)
//        shadowView.isHidden = true
//        self.isHidden = true
//        UIView.animate(withDuration: 1) {
//            self.shadowView.isHidden = false
//            self.isHidden = false
//        }
    }
    
    func dismiss()  {
        UIView.animate(withDuration: 1) {
            self.removeFromSuperview()
            self.shadowView.removeFromSuperview()
        }
        
    }
    
    @objc func buttonClick(btn: UIButton) {
        let index = btn.tag - BASIC_TAG
        let handle = actions[index].handle
        handle()
        dismiss()
        
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
