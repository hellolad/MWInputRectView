//
//  MWInputRectView.swift
//  SwiftUITest
//
//  Created by hellolad on 2018/5/8.
//  Copyright © 2018年 HenryChao. All rights reserved.
//

import UIKit

private extension Selector {
    static let becomeFoucsTapped = #selector(MWInputRectView._becomeFoucsTapped(_:))
    static let hiddenTFValueChanged = #selector(MWInputRectView._hiddenTFValueChanged(_:))
}

typealias MWInputRectNoParamters = () -> Void
typealias MWInputRectHasParamters = (String) -> Void

class MWInputRectView: UIView {
    // 默认是非第一响应者
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    /// 初始化验证码密码框等，becomFoucs: 启动是否是第一响应者，canBecomFoucs：是否可以在输入之后点击框框再次成为响应者
    convenience init(_ frame: CGRect,
                     becomeFoucs: Bool = true,
                     lineColor: UIColor = .black,
                     labColor: UIColor = .black) {
        self.init(frame: frame)
        self._drawLine(lineColor)
        self._drawHiddenTF(becomeFoucs)
        self._drawLabels(labColor)
        self._drawBecomeFoucsBtn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 隐藏的框
    private var hiddenTF: UITextField!
    /// 输入框中输入数字接收的数组
    private var inputCodes = Array(repeating: "", count: 6)
    /// 显示lab的数组labs
    private var showLabs = [UILabel]()
    /// 输入6个数字之后完成回调
    private var inputCodeFinishedClosure: MWInputRectHasParamters?
    /// 是否可以再次成为响应者
    var canBecomeFocus: Bool = true
    /// 是否以密码的形式展现
    var isSecureTextEntry: Bool = true
    /// 获取输入好的验证码
    var finishedCode: String? {
        if self._checkInputCodesValue() {
            return self.inputCodes.joined(separator: "")
        } else {
            return nil
        }
    }
}

//MARK: MWInputRectView - public
extension MWInputRectView {
    /// 输入六个数之后完成 回调
    func inputCodeFinished(closure: @escaping MWInputRectHasParamters) {
        self.inputCodeFinishedClosure = closure
    }
    /// 清除框框中输入的所有数字
    func removeCodeInRect() {
        self.inputCodes.replaceSubrange(0..<self.inputCodes.count, with: Array(repeating: "", count: 6))
        zip(self.showLabs, self.inputCodes).forEach { lab, code in
            lab.text = code
        }
        if self.canBecomeFocus {
            self.hiddenTF.becomeFirstResponder()
        }
    }
}

//MARK: MWInputRectView - private
private extension MWInputRectView {
    private func _drawLine(_ lineColor: UIColor) {
        let rectPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 5, height: 5))
        let rectLayer = CAShapeLayer()
        rectLayer.path = rectPath.cgPath
        rectLayer.lineWidth = 2
        rectLayer.strokeColor = lineColor.cgColor
        rectLayer.fillColor = nil
        self.layer.addSublayer(rectLayer)
        rectPath.close()
        
        var index = 1
        let spaceWidth = bounds.width / 6
        while index <= 5 {
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: spaceWidth*index.f, y: 0))
            linePath.addLine(to: CGPoint(x: spaceWidth*index.f, y: bounds.height))
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineWidth = 2
            lineLayer.strokeColor = lineColor.cgColor
            lineLayer.fillColor = nil
            self.layer.addSublayer(lineLayer)
            linePath.close()
            index += 1
        }
    }
    private func _drawBecomeFoucsBtn() {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.clear
        btn.frame = bounds
        btn.addTarget(self, action: .becomeFoucsTapped, for: .touchUpInside)
        self.addSubview(btn)
    }
    private func _drawHiddenTF(_ becomeFoucs: Bool) {
        let tf = UITextField(frame: bounds)
        tf.backgroundColor = .red
        tf.textColor = UIColor.white
        tf.addTarget(self, action: .hiddenTFValueChanged, for: .editingChanged)
        self.addSubview(tf)
        self.hiddenTF = tf
        self.hiddenTF.keyboardType = .numberPad
        self.hiddenTF.isHidden = true
        if becomeFoucs {
            self.hiddenTF.becomeFirstResponder()
        }
    }
    private func _drawLabels(_ labColor: UIColor) {
        for index in 0..<6 {
            let labWidth = bounds.width/6
            let frame = CGRect(x: index.f*labWidth, y: 0, width: labWidth, height: labWidth)
            let lab = UILabel(frame: frame)
            lab.text = ""
            lab.textColor = labColor
            lab.textAlignment = .center
            if #available(iOS 8.2, *) {
                lab.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            } else {
                lab.font = UIFont.boldSystemFont(ofSize: 25)
            }
            self.addSubview(lab)
            self.showLabs.append(lab)
        }
    }
    @objc func _becomeFoucsTapped(_ btn: UIButton) {
        if self.canBecomeFocus {
            self.hiddenTF.becomeFirstResponder()
        }
    }
    @objc func _hiddenTFValueChanged(_ tf: UITextField) {
        guard let text = tf.text else { return }
        if MWInputRect.Regular.lessThan(text) {
            self._handelCodesStatus(text)
        } else {
            let index = text.index(text.startIndex, offsetBy: 6)
            let t = text[..<index]
            tf.text = String(t)
        }
        if _checkInputCodesValue() {
            print("already input 6 numbers.")
            tf.resignFirstResponder()
            self._inputCodeFinishClosure()
        }
    }
    // 处理输入删除数组的变化
    private func _handelCodesStatus(_ text: String) {
        let temps = Array(repeating: "", count: 6)
        let texts = text.map { String($0) }
        for (index, element) in temps.enumerated() {
            if index < texts.count {
                self.inputCodes[index] = texts[index]
            } else {
                self.inputCodes[index] = element
            }
        }
        zip(self.showLabs, self.inputCodes).enumerated().forEach { (index, element:(lab: UILabel, code: String)) in
            if !self.isSecureTextEntry {
                element.lab.text = element.code
            } else {
                if element.code == "" {
                    element.lab.text = ""
                } else {
                    element.lab.text = "*"
                }
            }
        }
    }
    // 判断inputCodes里是否都是""空字符串
    private func _checkInputCodesValue() -> Bool {
        guard let first = self.inputCodes.first, let last = self.inputCodes.last else {
            return false
        }
        if first == "" || last == "" {
            return false
        }
        return true
    }
    // 输入6个数字完成之后的回调
    private func _inputCodeFinishClosure() {
        guard let closure = self.inputCodeFinishedClosure else {
            return
        }
        let text = inputCodes.joined(separator: "")
        closure(text)
    }
    
}


//MARK: Extension
private extension Int {
    var f: CGFloat {
        return self.float()
    }
    private func float() -> CGFloat {
        return CGFloat(self)
    }
}

private extension Double {
    var f: CGFloat {
        return self.float()
    }
    private func float() -> CGFloat {
        return CGFloat(self)
    }
}

//MARK: MWInputRect
private enum MWInputRect {
    enum Regular {
        static func lessThan(_ string: String) -> Bool {
            let regx = "[0-9]{0,6}"
            guard let rangeIndex = string.range(of: regx, options: .regularExpression, range: string.startIndex..<string.endIndex, locale: nil) else {
                return false
            }
            if rangeIndex.upperBound.encodedOffset == string.count {
                return true
            }
            return false
        }
    }
}
