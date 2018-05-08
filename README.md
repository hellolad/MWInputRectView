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
