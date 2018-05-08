最近一段时间因为公司项目需要支付功能，需要提交支付密码框和验证码的框，网上的三方库也有不少，但是很多功能复杂，有些定制性太强都不太满意，然后就就自己进行了自定义，今天趁机又优化了一下，先看效果图：
![gif.gif](https://upload-images.jianshu.io/upload_images/1786359-739abe70d86a9c1e.gif?imageMogr2/auto-orient/strip)

忽略丑陋的页面...
下面进入整体如何实现：
##### 思路：
1. 使用贝塞尔曲线画圆角框和垂直线条
2. 在当前的这个(MWInputRectView)view上增加UITextFied并隐藏
3. 还是这个view上添加UIButton来重新获取第一响应者
4. 使用数组保存UILabel和输入的验证码Code
5. 通过遍历数组吧Code映射到Label上
6. 输入完毕之后回调给控制器做下一步处理
##### 动手实现：
`MWInputRectView`
```
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
```
- 可简单配置输入框和响应者
```
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
```
- 其他公共函数
```
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
```
- 使用贝塞尔曲线画线条和框
```
private func _drawLine(_ lineColor: UIColor) {
    let rectPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 5, height: 5))
    let rectLayer = CAShapeLayer()
    rectLayer.path = rectPath.cgPath
    rectLayer.lineWidth = 2
    rectLayer.strokeColor = lineColor.cgColor
    rectLayer.fillColor = nil
    self.layer.addSublayer(rectLayer)
    
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
        index += 1
    }
}
```
