//
//  ViewController.swift
//  ScrollingAdvertisingView-Swift
//
//  Created by zhifu360 on 2018/11/23.
//  Copyright © 2018 ZZJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let cellID = "cellID"
    
    lazy var scrollingAdvertisingView:ScrollingAdvertisingView = {
        let view = ScrollingAdvertisingView(frame: CGRect(x: 20, y: (UIScreen.main.bounds.size.height - 60) / 2, width: UIScreen.main.bounds.size.width - 40, height: 60))
        view.registClass(t_Class: ScrollingAdvertisingCell.self, reuseIdentifier: cellID)
        view.AllowDebug = true
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    let dataArray = ["为国家谋发展，也为世界作贡献，这是中国人民赋予自己的神圣职责。","40年改革开放，中国不仅发展了自己，也造福了世界。","“落其实思其树，饮其流怀其源”。","在亚太经合组织第二十六次领导人非正式会议上，习近平主席又重申中国将坚持对外开放基本国策，大幅度放宽市场准入，加大保护知识产权力度，创造更具吸引力的投资和营商环境。"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "ViewController"
    
        view.backgroundColor = .white
        
        view.addSubview(self.scrollingAdvertisingView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollingAdvertisingView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.scrollingAdvertisingView.releaseTimer()
    }
}

extension ViewController:ScrollingAdvertisingViewDelegate,ScrollingAdvertisingViewDatasource {
    
    func didSelectedCell(scrollAdvertisingView: ScrollingAdvertisingView, index: Int) {
        print("index===\(index)")
    }
    
    func scrollingAdvertisingView(scrollAdvertisingView: ScrollingAdvertisingView, cellAtIndex index: Int) -> ScrollingAdvertisingCell {
        let cell = scrollAdvertisingView.dequeueReusableCell(identifier: cellID)
        cell.textLabel?.text = self.dataArray[index]
        cell.textLabel?.textColor = .white
        cell.contentView?.backgroundColor = UIColor(red: (CGFloat)(arc4random()%256)/255.0, green: (CGFloat)(arc4random()%256)/255.0, blue: (CGFloat)(arc4random()%256)/255.0, alpha: 1.0)
        return cell
    }
    
    func numberOfRows(scrollingAdvertisingView: ScrollingAdvertisingView) -> Int {
        return self.dataArray.count
    }
}
