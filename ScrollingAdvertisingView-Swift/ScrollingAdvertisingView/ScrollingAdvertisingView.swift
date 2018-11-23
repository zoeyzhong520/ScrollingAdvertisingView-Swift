//
//  ScrollingAdvertisingView.swift
//  ScrollingAdvertisingView-Swift
//
//  Created by zhifu360 on 2018/11/23.
//  Copyright © 2018 ZZJ. All rights reserved.
//

import UIKit

///dataSource
@objc protocol ScrollingAdvertisingViewDatasource: NSObjectProtocol {
    ///行数
    func numberOfRows(scrollingAdvertisingView: ScrollingAdvertisingView) -> Int
    ///Cell实体
    func scrollingAdvertisingView(scrollAdvertisingView: ScrollingAdvertisingView, cellAtIndex index: Int) -> ScrollingAdvertisingCell
}

///delegate
@objc protocol ScrollingAdvertisingViewDelegate: NSObjectProtocol {
    ///点击某个Cell
    func didSelectedCell(scrollAdvertisingView: ScrollingAdvertisingView, index: Int)
}

class ScrollingAdvertisingView: UIView {

    ///是否开启调试
    var AllowDebug:Bool = false
    ///滚动间隔，默认2s
    var rollingInterval: TimeInterval = 0
    ///当前滚动值
    private(set) var currentIndex:Int = 0
    ///方法代理
    weak var delegate:ScrollingAdvertisingViewDelegate?
    ///数据源代理
    weak var dataSource:ScrollingAdvertisingViewDatasource?
    ///存储reuseIdentifier的字典
    fileprivate var reuseIdentifierDict = NSMutableDictionary()
    ///存储Cell的数组
    fileprivate var reuseCells = NSMutableArray()
    ///是否动画
    fileprivate var isAnimating:Bool = false
    ///是否延迟加载计时器
    fileprivate var isTimerLazy:Bool = false
    ///计时器
    fileprivate var timer:DispatchSourceTimer!
    ///CurrentCell
    fileprivate var currentCell:ScrollingAdvertisingCell?
    ///WillShowCell
    fileprivate var willShowCell:ScrollingAdvertisingCell?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initParameters()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initParameters()
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if AllowDebug {
            print("\((#file as NSString).lastPathComponent) \(#line) \(#function)")
        }
    }
}

//MARK: - Implementation
extension ScrollingAdvertisingView {
    
    ///使用reuseIdentifier注册
    func registClass<T>(t_Class: T, reuseIdentifier: String) {
        reuseIdentifierDict.setObject(NSStringFromClass(t_Class as! AnyClass), forKey: reuseIdentifier as NSCopying)
    }
    
    ///使用UINib注册
    func registNib(nib: UINib, reuseIdentifier: String) {
        reuseIdentifierDict.setObject(nib, forKey: reuseIdentifier as NSCopying)
    }
    
    ///从复用池取出Cell
    func dequeueReusableCell(identifier: String) -> ScrollingAdvertisingCell {
        
        for i in 0..<reuseCells.count {
            let cell = reuseCells[i] as? ScrollingAdvertisingCell
            if cell?.reuseIdentifier == identifier {
                return cell!
            }
        }
        
        if let cellClass = reuseIdentifierDict.object(forKey: identifier) as? UINib {
            let array = cellClass.instantiate(withOwner: nil, options: nil)
            let cell = array.first as? ScrollingAdvertisingCell
            cell?.setValue(identifier, forKeyPath: "reuseIdentifier")
            return cell!
        } else {
            let className = reuseIdentifierDict.object(forKey: identifier) as? String ?? ""
            guard let t_Class = NSClassFromString(className) as? ScrollingAdvertisingCell.Type else {
                fatalError("无法转换成ScrollingAdvertisingCell")
            }
            let cell = t_Class.init(reuseIdentifier: identifier)
            return cell
        }
    }
    
    ///刷新数据
    func reloadData() {
        
        //布局CurrentCell和WillShowCell
        layoutCurrentCellAndWillShowCell()
        
        //判断个数小于2不执行滚动
        let count = self.dataSource?.numberOfRows(scrollingAdvertisingView: self)
        if count != nil && count! < 2 {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (isTimerLazy ? rollingInterval : 0)) {
            self.startTimer()
        }
    }
    
    ///释放Timer
    func releaseTimer() {
        timer.cancel()
        isAnimating = false
        currentIndex = 0
        currentCell?.removeFromSuperview()
        willShowCell?.removeFromSuperview()
        reuseCells.removeAllObjects()
    }
    
    ///配置参数
    fileprivate func initParameters() {
        rollingInterval = 2
        clipsToBounds = true
    }
    
    ///开启计时器
    fileprivate func startTimer() {
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: rollingInterval)
        timer.setEventHandler {
            DispatchQueue.main.async {
                self.timerMove()
            }
        }
        timer.resume()
    }
    
    ///计时器回调方法
    fileprivate func timerMove() {
        
        if isAnimating {
            return
        }
        
        //布局CurrentCell和WillShowCell
        layoutCurrentCellAndWillShowCell()
        
        //CurrentIndex自增
        currentIndex += 1
        
        isAnimating = true
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
            self.currentCell?.frame = CGRect(x: 0, y: -self.bounds.size.height, width: self.bounds.size.width, height: self.bounds.size.height)
            self.willShowCell?.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        }) { (finished) in
            if self.currentCell != nil && self.willShowCell != nil {
                self.reuseCells.add(self.currentCell!)
                self.currentCell?.removeFromSuperview()
                self.currentCell = self.willShowCell
            }
            self.isAnimating = false
        }
        
    }
    
    ///布局CurrentCell和WillShowCell
    fileprivate func layoutCurrentCellAndWillShowCell() {
        
        //判断界限
        let count = self.dataSource?.numberOfRows(scrollingAdvertisingView: self)
        if count != nil && currentIndex > count!-1 {
            currentIndex = 0
        }
        
        var willShowIndex = currentIndex + 1
        if count != nil && willShowIndex > count!-1 {
            willShowIndex = 0
        }
        
        //初始化时创建CurrentCell
        if currentCell == nil {
            currentCell = self.dataSource?.scrollingAdvertisingView(scrollAdvertisingView: self, cellAtIndex: currentIndex)
            currentCell?.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
            addSubview(currentCell!)
            //计时器延迟加载
            isTimerLazy = true
            return
        }
        
        //计时器正常加载
        isTimerLazy = false
        
        willShowCell = self.dataSource?.scrollingAdvertisingView(scrollAdvertisingView: self, cellAtIndex: willShowIndex)
        willShowCell?.frame = CGRect(x: 0, y: self.bounds.size.height, width: self.bounds.size.width, height: self.bounds.size.height)
        addSubview(willShowCell!)
        
        reuseCells.remove(currentCell!)
        reuseCells.remove(willShowCell!)
    }
    
    ///获取AppName
    fileprivate func appName() -> String {
        return (Bundle.main.infoDictionary!["CFBundleExecutable"] as! String).replacingOccurrences(of: "-", with: "_")
    }
}
