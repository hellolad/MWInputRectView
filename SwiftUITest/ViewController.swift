//
//  ViewController.swift
//  SwiftUITest
//
//  Created by hellolad on 2018/5/8.
//  Copyright © 2018年 HenryChao. All rights reserved.
//

import UIKit

enum MW {
    enum screen {
        static let width = UIScreen.main.bounds.width
        static let heiht = UIScreen.main.bounds.height
        static let size = UIScreen.main.bounds
    }
}

class ViewController: UIViewController {
    
    private var inputRectView: MWInputRectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red:0.21, green:0.23, blue:0.25, alpha:1.00)
        
        let inputWidth = 55 * 6
        let frame = CGRect(x: Int((MW.screen.width-CGFloat(inputWidth))/2), y: 100, width: inputWidth, height: 55)
        let inputRectView = MWInputRectView(frame,
                                            becomeFoucs: true,
                                            lineColor: .white,
                                            labColor: .white)
        inputRectView.isSecureTextEntry = false
        view.addSubview(inputRectView)
        self.inputRectView = inputRectView
        //inputRectView.inputCodeFinished(closure: { code in
//            print("code = \(code)")
        //})
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(self.inputRectView.finishedCode)
    }

}

