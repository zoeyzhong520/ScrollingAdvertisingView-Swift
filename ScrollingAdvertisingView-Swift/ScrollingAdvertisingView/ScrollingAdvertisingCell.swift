//
//  ScrollingAdvertisingCell.swift
//  ScrollingAdvertisingView-Swift
//
//  Created by zhifu360 on 2018/11/23.
//  Copyright © 2018 ZZJ. All rights reserved.
//

import UIKit

class ScrollingAdvertisingCell: UIView {

    ///是否开启调试信息
    var AllowDebug:Bool = false
    ///重用标识
    private(set) var reuseIdentifier:String?
    ///呈现控件的基础View
    private(set) var contentView:UIView?
    ///显示文本的label
    private(set) var textLabel:UILabel?
    
    ///使用reuseIdentifier初始化
    required init(reuseIdentifier:String) {
        super.init(frame: .zero)
        baseInit()
    }
    
    required convenience init() {
        self.init(reuseIdentifier: "")
    }
    
    ///使用Coder初始化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if AllowDebug {
            //文件+行数+方法
            print("\((#file as NSString).lastPathComponent) \(#line) \(#function)")
        }
    }
}

//MARK: - 基础配置
extension ScrollingAdvertisingCell {
    
    fileprivate func baseInit() {
        contentView = UIView()
        addSubview(contentView!)
        
        textLabel = UILabel()
        contentView?.addSubview(textLabel!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView?.frame = self.bounds
        textLabel?.frame = CGRect(x: 15, y: 0, width: contentView!.bounds.size.width - 30, height: contentView!.bounds.size.height)
    }
}
