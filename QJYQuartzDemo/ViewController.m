//
//  ViewController.m
//  QJYQuartzDemo
//
//  Created by QiuJunyun on 16/5/5.
//  Copyright © 2016年 QiuJunyun. All rights reserved.
//


/**
 * 1.UIBezierPath 是UIKit的方法
 * 2.CG的是Core Graphics的方法
 * 3.UIKit和Core Graphics可以在相同的图形上下文中混合使用。在iOS 4.0之前，使用UIKit和
 *   UIGraphicsGetCurrentContext被认为是线程不安全的。而在iOS4.0以后苹果让绘图操作在第二
 *   个线程中执行解决了此问题。
 * 4.为什么会发生倒置问题：
 *   究其原因是因为Core Graphics源于Mac OS X系统，在Mac OS X中，坐标原点在左下方并且正y坐
 *   标是朝上的，而在iOS中，原点坐标是在左上方并且正y坐标是朝下的。在大多数情况下，这不会出现
 *   任何问题，因为图形上下文的坐标系统是会自动调节补偿的。但是创建和绘制一个CGImage对象时就会
 *   暴露出倒置问题。
 * 5.在UIImageView子类中覆盖drawRect：方法是不合法的，你将得不到你绘制的图形。 在UIView子
 *   类的drawRect：方法中无需调用super，因为本身UIView的drawRect：方法是空的。为了提高一
 *   些绘图性能，你可以调用setNeedsDisplayInRect方法重新绘制视图的子区域，而视图的其他部分
 *   依然保持不变。
 * 6.为了提高一些绘图性能，你可以调用setNeedsDisplayInRect方法重新绘制视图的子区域，而视图
 *   的其他部分依然保持不变。
 * 7.当视图的backgroundColor为nil并且opaque属性为YES，视图的背景颜色就会变成黑色。
 * 8.因此一般绘图模式是：在绘图之前调用CGContextSaveGState函数保存当前状态，接着根据需要设
 *   置某些上下文状态，然后绘图，最后调用CGContextRestoreGState函数将当前状态恢复到绘图之前
 *   的状态。要注意的是，CGContextSaveGState函数和CGContextRestoreGState函数必须成对出
 *   现，否则绘图很可能出现意想不到的错误。
 *   - (void)drawRect:(CGRect)rect {
 *       CGContextRef ctx = UIGraphicsGetCurrentContext();
 *       CGContextSaveGState(ctx); {
 *       // 绘图代码
 *       }
 *       CGContextRestoreGState(ctx);
 *   }
 * 9.一些属性和对应修改属性的函数
 *   线条的宽度和线条的虚线样式
 *   CGContextSetLineWidth、CGContextSetLineDash
 *   线帽和线条联接点样式
 *   CGContextSetLineCap、CGContextSetLineJoin、CGContextSetMiterLimit
 *   线条颜色和线条模式
 *   CGContextSetRGBStrokeColor、CGContextSetGrayStrokeColor、CGContextSetStrokeColorWithColor、CGContextSetStrokePattern
 *   填充颜色和模式
 *   CGContextSetRGBFillColor,CGContextSetGrayFillColor,CGContextSetFillColorWithColor, CGContextSetFillPattern
 *   阴影
 *   CGContextSetShadow、CGContextSetShadowWithColor
 *   混合模式
 *   CGContextSetBlendMode（决定你当前绘制的图形与已经存在的图形如何被合成）
 *   整体透明度
 *   CGContextSetAlpha（个别颜色也具有alpha成分）
 *   文本属性
 *   CGContextSelectFont、CGContextSetFont、CGContextSetFontSize、CGContextSetTextDrawingMode、CGContextSetCharacterSpacing
 *   是否开启反锯齿和字体平滑
 *   CGContextSetShouldAntialias、CGContextSetShouldSmoothFonts
 * 10.下面列出了一些路径描画的命令：
 *    定位当前点
 *    CGContextMoveToPoint
 *    描画一条线
 *    CGContextAddLineToPoint、CGContextAddLines
 *    描画一个矩形
 *    CGContextAddRect、CGContextAddRects
 *    描画一个椭圆或圆形
 *    CGContextAddEllipseInRect
 *    描画一段圆弧
 *    CGContextAddArcToPoint、CGContextAddArc
 *    通过一到两个控制点描画一段贝赛尔曲线
 *    CGContextAddQuadCurveToPoint、CGContextAddCurveToPoint
 *    关闭当前路径
 *    CGContextClosePath 这将从路径的终点到起点追加一条线。如果你打算填充一段路径，那么就不需要使用该命令，因为该命令会被自动调用。
 *    描边或填充当前路径
 *    CGContextStrokePath、CGContextFillPath、CGContextEOFillPath、CGContextDrawPath。
      对当前路径描边或填充会清除掉路径。如果你只想使用一条命令完成描边和填充任务，可以使用
      CGContextDrawPath命令，因为如果你只是使用CGContextStrokePath对路径描边，路径就会被
      清除掉，你就不能再对它进行填充了。
 *    创建路径并描边路径或填充路径只需一条命令就可完成的函数：CGContextStrokeLineSegments、
      CGContextStrokeRect、CGContextStrokeRectWithWidth、CGContextFillRect、
      CGContextFillRects、CGContextStrokeEllipseInRect、CGContextFillEllipseInRect。
 *    一段路径是被合成的，意思是它是由多条独立的路径组成。举个例子，一条单独的路径可能由两个独
      立的闭合形状组成：一个矩形和一个圆形。当你在构造一条路径的中间过程（意思是在描画了一条路
      径后没有调用描边或填充命令，或调用CGContextBeginPath函数来清除路径）调用
      CGContextMoveToPoint函数，就像是你拾起画笔，并将画笔移动到一个新的位置，如此来准备开
      始一段独立的相同路径。如果你担心当你开始描画一条路径的时候，已经存在的路径和新的路径会被
      认为是已存在路径的一个合成部分，你可以调用CGContextBeginPath函数指定你绘制的路径是一
      条独立的路径；苹果的许多例子都是这样做的，但在实际开发中我发现这是非必要的。
 * 11.阴影
      为了在绘图上加入阴影，可在绘图之前设置上下文的阴影值。阴影的位置表示为CGSize，如果
      CGSize的两个值都是正数，则表示阴影是朝下和朝右的。模糊度被表示为任何一个正数。苹果没有
      解释缩放的工作方式，但实验表明12是最佳的模糊度，99及以上的模糊度会让阴影变得不成形。
 * 12.CGContextFillRect(con, CGRectMake(100,0,1.0/self.contentScaleFactor,100));
      像素为1px的垂线
 * 13.填充一个路径的时候，路径里面的子路径都是独立填充的。
      假如是重叠的路径，决定一个点是否被填充，有两种规则
      1.nonzero winding number rule:非零绕数规则，假如一个点被从左到右跨过，计数器+1，从右到左跨过，计数器-1，最后，如果结果是0，那么不填充，如果是非零，那么填充。
      2.even-odd rule: 奇偶规则，假如一个点被跨过，那么+1，最后是奇数，那么要被填充，偶数则不填充，和方向没有关系。
      http://blog.csdn.net/freshforiphone/article/details/8273023
**/

#import "ViewController.h"
//**********************************1*****************************************//
@interface MyView1 : UIView

@end

@implementation MyView1
/// 第一种绘图形式：在UIView的子类方法drawRect：中绘制一个蓝色圆，使用UIKit在Cocoa为我们提供
/// 的当前上下文中完成绘图任务
- (void)drawRect:(CGRect)rect {
    UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)];
    [[UIColor blueColor] setFill];
    [p fill];
}

@end
//***********************************2****************************************//

@interface MyView2 : UIView

@end

@implementation MyView2
///第二种绘图形式：使用Core Graphics实现绘制蓝色圆。
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, 100, 100));
//    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor greenColor] CGColor]));
    CGContextFillPath(ctx);
}

@end
//************************************3***************************************//
@interface MyView3LayerDelegate : NSObject

@end

@implementation MyView3LayerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    UIGraphicsPushContext(ctx);
    UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)];
    [[UIColor blueColor] setFill];
    [p fill];
    UIGraphicsPopContext();
}

@end


@interface MyView3 : UIView {
    MyView3LayerDelegate *_layerDelegate;
}

@end

@implementation MyView3
/**
 * 第三种绘图形式：我将在UIView子类的drawLayer:inContext：方法中实现绘图任务。
 * drawLayer:inContext：方法是一个绘制图层内容的代理方法。为了能够调用
 * drawLayer:inContext：方法，我们需要设定图层的代理对象。但要注意，不应该将UIView对象设置
 * 为显示层的委托对象，这是因为UIView对象已经是隐式层的代理对象，再将它设置为另一个层的委托对象
 * 就会出问题。轻量级的做法是：编写负责绘图形的代理类。在MyView.h文件中声明如下代码：
 * 不能再将某个UIView设置为CALayer的delegate，因为UIView对象已经是它内部根层的delegate，
 * 再次设置为其他层的delegate就会出问题。
**/
- (instancetype)init {
    if (self = [super init]) {
        CALayer *myLayer = [CALayer layer];
        _layerDelegate = [[MyView3LayerDelegate alloc] init];
        myLayer.bounds = CGRectMake(0, 0, 100, 100);
        myLayer.position = CGPointMake(100, 100);
        myLayer.delegate = _layerDelegate;
        // 调用此方法且存在frame，drawLayer:inContext:方法才会被调用
        [myLayer setNeedsDisplay];
        [self.layer addSublayer:myLayer];
    }
    return self;
}


@end
//*****************************************4**********************************//
@interface MyView4LayerDelegate : NSObject

@end

@implementation MyView4LayerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, 100, 100));
    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextFillPath(ctx);
}
@end


@interface MyView4 : UIView {
    MyView4LayerDelegate *_layerDelegate;
}

@end

@implementation MyView4
///使用Core Graphics在drawLayer:inContext：方法中实现view3
- (instancetype)init {
    if (self = [super init]) {
        CALayer *myLayer = [CALayer layer];
        _layerDelegate = [[MyView4LayerDelegate alloc] init];
        myLayer.bounds = CGRectMake(0, 0, 100, 100);
        myLayer.position = CGPointMake(100, 100);
        myLayer.delegate = _layerDelegate;
        [myLayer setNeedsDisplay];
        [self.layer addSublayer:myLayer];
    }
    return self;
}
@end
//*****************************************5**********************************//
@interface MyView5 : UIView
@end

@implementation MyView5
/// UIGraphicsBeginImageContextWithOptions UIKit
- (instancetype)init {
    if (self = [super init]) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), NO, 0);
        UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)];
        [[UIColor blueColor] setFill];
        [p fill];
        UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        imageView.image = im;
        [self addSubview:imageView];
    }
    return self;
}
@end
//*****************************************6**********************************//
@interface MyView6 : UIView
@end

@implementation MyView6
/// UIGraphicsBeginImageContextWithOptions Core Graphics
- (instancetype)init {
    if (self = [super init]) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), NO, 0);
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextAddEllipseInRect(con, CGRectMake(0, 0, 100, 100));
        CGContextSetFillColorWithColor(con, [UIColor blueColor].CGColor);
        CGContextFillPath(con);
        UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        imageView.image = im;
        [self addSubview:imageView];
    }
    return self;
}
@end
//*****************************************7**********************************//
@interface MyView7 : UIView
@end

@implementation MyView7
///
- (instancetype)init {
    if (self = [super init]) {
        UIImage *mars = [UIImage imageNamed:@"comment_head"];
        CGSize sz = [mars size];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(sz.width*2, sz.height), NO, 0);
        [mars drawAtPoint:CGPointMake(0, 0)];
        [mars drawAtPoint:CGPointMake(sz.width, 0)];
        UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *iv = [[UIImageView alloc] initWithImage:im];
        iv.frame = CGRectMake(0, 0, sz.width*2, sz.height);
        [self addSubview:iv];
    }
    return self;
}
@end
//*****************************************8**********************************//
@interface MyView8 : UIView
@end

@implementation MyView8
///
- (instancetype)init {
    if (self = [super init]) {
        UIImage *mars = [UIImage imageNamed:@"comment_head"];
        CGSize sz = [mars size];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(sz.width*2, sz.height*2), NO, 0);
        [mars drawInRect:CGRectMake(0, 0, sz.width*2, sz.height*2)];
        [mars drawInRect:CGRectMake(sz.width/2.0, sz.height/2.0, sz.width, sz.height)
               blendMode:kCGBlendModeMultiply alpha:1.0];
        UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *iv = [[UIImageView alloc] initWithImage:im];
        iv.frame = CGRectMake(0, 0, sz.width*2, sz.height*2);
        [self addSubview:iv];
    }
    return self;
}
@end
//*****************************************9**********************************//
@interface MyView9 : UIView
@end

@implementation MyView9
///
- (instancetype)init {
    if (self = [super init]) {
        UIImage *mars = [UIImage imageNamed:@"comment_head"];
        CGSize sz = [mars size];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(sz.width/2.0, sz.height), NO, 0);
        [mars drawAtPoint:CGPointMake(-sz.width/2.0, 0)];
        UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *iv = [[UIImageView alloc] initWithImage:im];
        iv.frame = CGRectMake(0, 0, sz.width/2.0, sz.height);
        [self addSubview:iv];
    }
    return self;
}
@end
//*****************************************10*********************************//
@interface MyView10 : UIView
@end

@implementation MyView10
///
- (instancetype)init {
    if (self = [super init]) {
        UIImage *mars = [UIImage imageNamed:@"comment_head"];
        CGSize sz = [mars size];
        /**
         * 在双分辨率的设备上，如果我们的图片文件是高分辨率（@2x）版本，上面的绘图就是错误的。
         * 原因在于对于UIImage来说，在加载原始图片时使用imageNamed:方法，它会自动根据所在
         * 设备的分辨率类型选择图片，并且UIImage通过设置用来适配的scale属性补偿图片的两倍尺
         * 寸。但是一个CGImage对象并没有scale属性，它不知道图片文件的尺寸是否为两倍！所以当
         * 调用UIImage的CGImage方法，你不能假定所获得的CGImage尺寸与原始UIImage是一样的。
         * 在单分辨率和双分辨率下，一个UIImage对象的size属性值都是一样的，但是双分辨率
         * UIImage对应的CGImage是单分辨率UIImage对应的CGImage的两倍大。
        **/
        CGImageRef marsCG = [mars CGImage];
        CGSize szCG = CGSizeMake(CGImageGetWidth(marsCG), CGImageGetHeight(marsCG));
        // 抽取图片的左右半边
        CGImageRef marsLeft = CGImageCreateWithImageInRect(marsCG, CGRectMake(0, 0, szCG.width/2.0, szCG.height));
        CGImageRef marsRight = CGImageCreateWithImageInRect(marsCG, CGRectMake(szCG.width/2.0, 0, szCG.width/2.0, szCG.height));
        // 将每一个CGImage绘制到图形上下文中
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(sz.width*1.5, sz.height), NO, 0);
//        // 使用flip方法翻转图片
//        CGContextRef con = UIGraphicsGetCurrentContext();
//        CGContextDrawImage(con, CGRectMake(0, 0, sz.width/2.0, sz.height), flip(marsLeft));
//        CGContextDrawImage(con, CGRectMake(sz.width, 0, sz.width/2.0, sz.height), flip(marsRight));
        /**
         * 可以在绘图之前将CGImage包装进UIImage中，这样做有两大优点：1.当UIImage绘图时它
         * 会自动修复倒置问题2.当你从CGImage转化为Uimage时，可调用
         * imageWithCGImage:scale:orientation:方法生成CGImage作为对缩放性的补偿。
        **/
        [[UIImage imageWithCGImage:marsLeft scale:[mars scale]
                       orientation:UIImageOrientationUp]
         drawAtPoint:CGPointMake(0, 0)];
        [[UIImage imageWithCGImage:marsRight scale:[mars scale]
                       orientation:UIImageOrientationUp]
         drawAtPoint:CGPointMake(sz.width, 0)];
        UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(marsLeft);
        CGImageRelease(marsRight);
        UIImageView *iv = [[UIImageView alloc] initWithImage:im];
        iv.frame = CGRectMake(0, 0, sz.width*1.5, sz.height);
        [self addSubview:iv];
    }
    return self;
}
/** 
 * 因为原始的本地坐标系统（坐标原点在左上角）与目标上下文（坐标原点在左下角）不匹配
 * 使用CGContextDrawImage方法先将CGImage绘制到UIImage上，然后获取UIImage对应的CGImage，
 * 此时就得到了一个倒转的CGImage。当再调用CGContextDrawImage方法，我们就将倒转的图片还原回
 * 来了。
**/
CGImageRef flip(CGImageRef im) {
    CGSize sz = CGSizeMake(CGImageGetWidth(im), CGImageGetHeight(im));
    UIGraphicsBeginImageContextWithOptions(sz, NO, 0);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, sz.width, sz.height), im);
    CGImageRef result = [UIGraphicsGetImageFromCurrentImageContext() CGImage];
    UIGraphicsEndImageContext();
    return result;
}

@end
//*****************************************11**********************************//
@interface MyView11 : UIView
@end

@implementation MyView11
///
- (instancetype)init {
    if (self = [super init]) {
        UIImage *mars = [UIImage imageNamed:@"comment_head"];
        CIImage *moi2 = [[CIImage alloc] initWithCGImage:mars.CGImage];
        CIFilter *grad = [CIFilter filterWithName:@"CIRadialGradient"];
        CIVector *center = [CIVector vectorWithX:mars.size.width/2.0 Y:mars.size.height / 2.0];
        // 使用setValue:forKey:方法设置滤镜属性
        [grad setValue:center forKey:@"inputCenter"];
        // 在指定滤镜名时提供所有滤镜键值对
        CIFilter *dart = [CIFilter filterWithName:@"CIDarkenBlendMode" keysAndValues:@"inputImage", grad.outputImage, @"inputBackgroundImage", moi2, nil];
        CIContext *c = [CIContext contextWithOptions:nil];
        CGImageRef moi3 = [c createCGImage:dart.outputImage fromRect:moi2.extent];
        UIImage *im = [UIImage imageWithCGImage:moi3 scale:mars.scale orientation:mars.imageOrientation];
        UIImageView *iv = [[UIImageView alloc] initWithImage:im];
        iv.frame = CGRectMake(0, 0, mars.size.width, mars.size.height);
        [self addSubview:iv];
    }
    return self;
}
@end
//*****************************************12*********************************//
@interface MyView12 : UIView
@end
@implementation MyView12
- (instancetype)init {
    if (self = [super init]) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0);
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(con, [UIColor blueColor].CGColor);
        CGContextFillRect(con, CGRectMake(0, 0, 40, 40));
        CGContextClearRect(con, CGRectMake(0, 0, 10, 10));
        UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *iv = [[UIImageView alloc] initWithImage:im];
        iv.frame = CGRectMake(0, 0, 40, 40);
        [self addSubview:iv];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), YES, 0);
        CGContextRef con1 = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(con1, [UIColor blueColor].CGColor);
        CGContextFillRect(con1, CGRectMake(0, 0, 40, 40));
        CGContextClearRect(con1, CGRectMake(0, 0, 10, 10));
        UIImage *im2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *iv2 = [[UIImageView alloc] initWithImage:im2];
        iv2.frame = CGRectMake(50, 0, 40, 40);
        [self addSubview:iv2];
    }
    return self;
}
@end
//*****************************************13*********************************//
@interface MyView13 : UIView
@end
@implementation MyView13
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 绘制一个黑色的垂直线，作为箭头的杆子
    CGContextMoveToPoint(ctx, 100, 100);
    CGContextAddLineToPoint(ctx, 100, 19);
    CGContextSetLineWidth(ctx, 20);
    CGContextStrokePath(ctx);
    // 绘制一个红色的三角形箭头
    CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]);
    CGContextMoveToPoint(ctx, 80, 25);
    CGContextAddLineToPoint(ctx, 100, 0);
    CGContextAddLineToPoint(ctx, 120, 25);
    CGContextFillPath(ctx);
    // 从箭头杆子上裁掉一个三角形，使用清除混合模式
    CGContextMoveToPoint(ctx, 90, 101);
    CGContextAddLineToPoint(ctx, 100, 90);
    CGContextAddLineToPoint(ctx, 110, 101);
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
//    CGContextSetBlendMode(ctx, kCGBlendModeClear);//没有生效
    CGContextFillPath(ctx);
}
@end
//*****************************************14*********************************//
@interface MyView14 : UIView
@end
@implementation MyView14
- (void)drawRect:(CGRect)rect {
    UIBezierPath *p = [UIBezierPath bezierPath];
    [p moveToPoint:CGPointMake(100, 100)];
    [p addLineToPoint:CGPointMake(100, 19)];
    [p setLineWidth:20];
    [p stroke];
    [[UIColor redColor] set];
    [p removeAllPoints];
    [p moveToPoint:CGPointMake(80, 25)];
    [p addLineToPoint:CGPointMake(100, 0)];
    [p addLineToPoint:CGPointMake(120, 25)];
    [p fill];
    [p removeAllPoints];
    [p moveToPoint:CGPointMake(90, 101)];
    [p addLineToPoint:CGPointMake(100, 90)];
    [p addLineToPoint:CGPointMake(110, 101)];
    [p fillWithBlendMode:kCGBlendModeClear alpha:1.0];
}
@end
//*****************************************15*********************************//
@interface MyView15 : UIView
@end
@implementation MyView15
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(ctx, 3);
    UIBezierPath *path;
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(100, 100, 100, 100) byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(10, 10)];
    [path stroke];
}
@end
//*****************************************16*********************************//
@interface MyView16 : UIView
@end
@implementation MyView16
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 从上下文裁剪区域中挖一个三角形状的孔
    CGContextMoveToPoint(ctx, 90, 100);
    CGContextAddLineToPoint(ctx, 100, 90);
    CGContextAddLineToPoint(ctx, 110, 100);
    CGContextClosePath(ctx);
    CGContextAddRect(ctx, CGContextGetClipBoundingBox(ctx));
    //使用奇偶规则，裁剪区域为矩形减去三角形区域
    CGContextEOClip(ctx);
    //绘制垂线
    CGContextMoveToPoint(ctx, 100, 100);
    CGContextAddLineToPoint(ctx, 100, 19);
    CGContextSetLineWidth(ctx, 20);
    CGContextStrokePath(ctx);
    //画红色箭头
    CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]);
    CGContextMoveToPoint(ctx, 80, 25);
    CGContextAddLineToPoint(ctx, 100, 0);
    CGContextAddLineToPoint(ctx, 120, 25);
    CGContextFillPath(ctx);
    
}
@end
//*****************************************17*********************************//
@interface MyView17 : UIView
@end
@implementation MyView17
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx); {
        // 从上下文裁剪区域中挖一个三角形状的孔
        CGContextMoveToPoint(ctx, 90, 100);
        CGContextAddLineToPoint(ctx, 100, 90);
        CGContextAddLineToPoint(ctx, 110, 100);
        CGContextClosePath(ctx);
        CGContextAddRect(ctx, CGContextGetClipBoundingBox(ctx));
        //使用奇偶规则，裁剪区域为矩形减去三角形区域
        CGContextEOClip(ctx);
        //绘制垂线,让它的轮廓形状成为裁剪区域
        CGContextMoveToPoint(ctx, 100, 100);
        CGContextAddLineToPoint(ctx, 100, 19);
        CGContextSetLineWidth(ctx, 20);
        //使用路径的描边版本替换图形上下文的路径
        CGContextReplacePathWithStrokedPath(ctx);
        //对路径的描边版本实施裁剪
        CGContextClip(ctx);
        //绘制渐变
        CGFloat locs[3] = {0.0, 0.5, 1.0};
        CGFloat colors[12] = {
          0.3, 0.3, 0.3, 0.8,// 开始颜色，透明灰
          0.0, 0.0, 0.0, 1.0,// 中间颜色，黑色
          0.3, 0.3, 0.3, 0.8 // 末尾颜色，透明灰
        };
        CGColorSpaceRef sp = CGColorSpaceCreateDeviceGray();
        CGGradientRef grad = CGGradientCreateWithColorComponents(sp, colors, locs, 3);
        CGContextDrawLinearGradient(ctx, grad, CGPointMake(89, 0), CGPointMake(111, 0), 0);
        CGContextDrawRadialGradient(ctx, grad, CGPointMake(50, 300), 20, CGPointMake(100, 300), 20, 0);
        CGColorSpaceRelease(sp);
        CGGradientRelease(grad);
    } CGContextRestoreGState(ctx);//完成裁剪
    //画红色箭头
//    CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]); //使用下面块中的代码CGPattern实现使用红蓝相间的三角形替换箭头的三角形部分
    {
        CGColorSpaceRef sp2 = CGColorSpaceCreatePattern(NULL);
        CGContextSetFillColorSpace(ctx, sp2);
        CGColorSpaceRelease(sp2);
        CGPatternCallbacks callback = {0, &drawStripes, NULL};
        CGAffineTransform tr = CGAffineTransformIdentity;
        CGFloat buf = 10;
        CGPatternRef patt = CGPatternCreate(&buf, CGRectMake(0, 0, 4, 4), tr, 4, 4, kCGPatternTilingConstantSpacingMinimalDistortion, false, &callback);
        CGFloat alph = 1.0;
        CGContextSetPatternPhase(ctx, CGSizeMake(40, 25));//CGContextSetPatternPhase函数改变模板的定位,不用这个最底部的似乎只平铺了一半蓝色。这是因为一个模板的定位并不关心你填充（描边）的形状，总的来说它只关心图形上下文。
        CGContextSetFillPattern(ctx, patt, &alph);
        
//        CGContextSetStrokePattern(ctx, patt, &alph);
        CGPatternRelease(patt);
        /**
        CGPatternCreate。一个模板是在一个矩形元中的绘图。我们需要矩形元的尺寸（第二个参数）以及矩形元原始点之间的间隙（第四和第五个参数）。这这种情况下，矩形元是4*4的，每一个矩形元与它的周围矩形元是紧密贴合的。我们需要提供一个应用到矩形元的变换参数（第三个参数）；在这种情况下，我们不需要变换做什么工作，所以我们应用了一个恒等变换。我们应用了一个瓷砖规则（第六个参数）。我们需要声明的是颜色模板不是漏印（stencil）模板，所以参数值为true。并且我们需要提供一个指向回调函数的指针，回调函数的工作是向矩形元绘制模板。第八个参数是一个指向CGPatternCallbacks结构体的指针。这个结构体由数字0和两个指向函数的指针构成。第一个函数指针指向的函数当模板被绘制到矩形元中被调用，第二个函数指针指向的函数当模板被释放后调用。第二个函数指针我们没有指定，它的存在主要是为了内存管理的需要。但在这个简单的例子中，我们并不需要。
         **/
    }
    CGContextMoveToPoint(ctx, 80, 25);
    CGContextAddLineToPoint(ctx, 100, 0);
    CGContextAddLineToPoint(ctx, 120, 25);
    CGContextFillPath(ctx);
    
}

void drawStripes(void *info, CGContextRef con) {
    // assume 4*4 cell
    CGContextSetFillColorWithColor(con, [[UIColor redColor] CGColor]);
    CGContextFillRect(con, CGRectMake(0, 0, 4, 4));//这里的绘制滑板4*4单元就是CGPatternCreate第二个参数，每个单元的原始点距离就是第四第五个参数
    CGContextSetFillColorWithColor(con, [[UIColor blueColor] CGColor]);
    CGContextFillRect(con, CGRectMake(0, 0, 4, 2));
    
//    CGContextSetStrokeColorWithColor(con, [[UIColor redColor] CGColor]);
//    CGContextStrokeRect(con, CGRectMake(0, 0, 4, 4));
//    CGContextSetStrokeColorWithColor(con, [[UIColor blueColor] CGColor]);
//    CGContextStrokeRect(con, CGRectMake(0, 0, 4, 2));
}

@end
//*****************************************18*********************************//
@interface MyView18 : UIView
@end
@implementation MyView18
- (void)drawRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 100), NO, 0.0);
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextSaveGState(con); {
            CGContextMoveToPoint(con, 90 - 80, 100);
            CGContextAddLineToPoint(con, 100 - 80, 90);
            CGContextAddLineToPoint(con, 110 - 80, 100);
            CGContextMoveToPoint(con, 110 - 80, 100);
            CGContextAddLineToPoint(con, 100 - 80, 90);
            CGContextAddLineToPoint(con, 90 - 80, 100);
            CGContextClosePath(con);
            CGContextAddRect(con, CGContextGetClipBoundingBox(con));
            CGContextEOClip(con);
            CGContextMoveToPoint(con, 100 - 80, 100);
            CGContextAddLineToPoint(con, 100 - 80, 19);
            CGContextSetLineWidth(con, 20);
            CGContextReplacePathWithStrokedPath(con);
            CGContextClip(con);
            CGFloat locs[3] = { 0.0, 0.5, 1.0 };
            CGFloat colors[12] = {
                .3, .3, .3, .8,
                .0, .0, .0, 1.0,
                .3, .3, .3, .8
            };
            CGColorSpaceRef sp = CGColorSpaceCreateDeviceGray();
            CGGradientRef grad = CGGradientCreateWithColorComponents(sp, colors, locs, 3);
            CGContextDrawLinearGradient(con, grad, CGPointMake(89 - 80, 0), CGPointMake(111 - 80, 0), 0);
            CGColorSpaceRelease(sp);
            CGGradientRelease(grad);
        } CGContextRestoreGState(con);
        CGColorSpaceRef sp2 = CGColorSpaceCreatePattern(NULL);
        CGContextSetFillColorSpace(con, sp2);
        CGColorSpaceRelease(sp2);
        CGPatternCallbacks callback = {0, &drawStripes, NULL};
        CGAffineTransform tr = CGAffineTransformIdentity;
        CGPatternRef patt = CGPatternCreate(NULL, CGRectMake(0, 0, 4, 4), tr, 4, 4, kCGPatternTilingConstantSpacingMinimalDistortion, true, &callback);
        CGFloat alph = 1.0;
        CGContextSetFillPattern(con, patt, &alph);
        CGPatternRelease(patt);
        CGContextMoveToPoint(con, 80 - 80, 25);
        CGContextAddLineToPoint(con, 100 - 80, 0);
        CGContextAddLineToPoint(con, 120 - 80, 25);
        CGContextFillPath(con);
        UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    {/// 绘制旋转
        con = UIGraphicsGetCurrentContext();
        for (int i = 0; i < 4; i ++) {
            [im drawAtPoint:CGPointMake(0, 0)];
            CGContextTranslateCTM(con, 20, 100);
            CGContextRotateCTM(con, 30 * M_PI/180.0);
            CGContextTranslateCTM(con, -20, -100);
        }
    }
}
@end
//*****************************************19*********************************//
@interface MyView19 : UIView
@end
@implementation MyView19

- (void)drawRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 100), NO, 0.0);
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextSaveGState(con); {
        CGContextMoveToPoint(con, 90 - 80, 100);
        CGContextAddLineToPoint(con, 100 - 80, 90);
        CGContextAddLineToPoint(con, 110 - 80, 100);
        CGContextMoveToPoint(con, 110 - 80, 100);
        CGContextAddLineToPoint(con, 100 - 80, 90);
        CGContextAddLineToPoint(con, 90 - 80, 100);
        CGContextClosePath(con);
        CGContextAddRect(con, CGContextGetClipBoundingBox(con));
        CGContextEOClip(con);
        CGContextMoveToPoint(con, 100 - 80, 100);
        CGContextAddLineToPoint(con, 100 - 80, 19);
        CGContextSetLineWidth(con, 20);
        CGContextReplacePathWithStrokedPath(con);
        CGContextClip(con);
        CGFloat locs[3] = { 0.0, 0.5, 1.0 };
        CGFloat colors[12] = {
            .3, .3, .3, .8,
            .0, .0, .0, 1.0,
            .3, .3, .3, .8
        };
        CGColorSpaceRef sp = CGColorSpaceCreateDeviceGray();
        CGGradientRef grad = CGGradientCreateWithColorComponents(sp, colors, locs, 3);
        CGContextDrawLinearGradient(con, grad, CGPointMake(89 - 80, 0), CGPointMake(111 - 80, 0), 0);
        CGColorSpaceRelease(sp);
        CGGradientRelease(grad);
    } CGContextRestoreGState(con);
    CGColorSpaceRef sp2 = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(con, sp2);
    CGColorSpaceRelease(sp2);
    CGPatternCallbacks callback = {0, &drawStripes, NULL};
    CGAffineTransform tr = CGAffineTransformIdentity;
    CGPatternRef patt = CGPatternCreate(NULL, CGRectMake(0, 0, 4, 4), tr, 4, 4, kCGPatternTilingConstantSpacingMinimalDistortion, true, &callback);
    CGFloat alph = 1.0;
    CGContextSetFillPattern(con, patt, &alph);
    CGPatternRelease(patt);
    CGContextMoveToPoint(con, 80 - 80, 25);
    CGContextAddLineToPoint(con, 100 - 80, 0);
    CGContextAddLineToPoint(con, 120 - 80, 25);
    CGContextFillPath(con);
    UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    con = UIGraphicsGetCurrentContext();
    { /// 添加阴影效果
        CGContextSetShadow(con, CGSizeMake(7, 7), 12);
        /**
         * 然而，使用这种方法有一个不太明显的问题。我们是在每绘制一个箭头的时候加上的阴影。因
         * 此，箭头的阴影会投射在另一个箭头上面。我们想要的是让所有的箭头集体地投射出一个阴影。
         * 解决方法是使用一个透明的图层；该图层类似一个先是叠加所有绘图然后加上阴影的一个子上
         * 下文。代码如下：
         **/
        {
            CGContextBeginTransparencyLayer(con, NULL);
        }
    }
    for (int i = 0; i < 4; i ++) {
        [im drawAtPoint:CGPointMake(0, 0)];
        CGContextTranslateCTM(con, 20, 100);
        CGContextRotateCTM(con, 30 * M_PI/180.0);
        CGContextTranslateCTM(con, -20, -100);
    }
    // 在调用了CGContextEndTransparencyLayer函数之后，
    // 图层内容会在应用全局alpha和上下文阴影状态之后被合成到上下文中
    {
        CGContextEndTransparencyLayer(con);
    }
}
@end
//*****************************************20*********************************//
@interface MyView20 : UIView
@end
@implementation MyView20
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, 20, 10);
    CGContextAddLineToPoint(ctx, 20, 100);
    CGContextAddLineToPoint(ctx, 100, 100);
    CGContextAddLineToPoint(ctx, 20, 20);
    CGContextAddLineToPoint(ctx, 100, 20);
    CGContextAddLineToPoint(ctx, 40, 70);
    CGContextAddLineToPoint(ctx, 40, 120);
    CGContextSetLineWidth(ctx, 5);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGFloat length[2] = {5, 5};
    CGContextSetLineDash(ctx, 0, length, 2);
    CGContextStrokePath(ctx);
    
    CGContextMoveToPoint(ctx, 20 + 120, 10);
    CGContextAddLineToPoint(ctx, 20 + 120, 100);
    CGContextAddLineToPoint(ctx, 100 + 120, 100);
    CGContextAddLineToPoint(ctx, 20 + 120, 20);
    CGContextAddLineToPoint(ctx, 100 + 120, 20);
    CGContextAddLineToPoint(ctx, 40 + 120, 70);
    CGContextAddLineToPoint(ctx, 40 + 120, 120);
    CGContextSetLineWidth(ctx, 5);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextSetLineJoin(ctx, kCGLineJoinMiter);
    CGContextSetMiterLimit(ctx, 2.9);
    CGContextSetLineDash(ctx, 0, NULL, 0);
    CGContextStrokePath(ctx);
}
@end
//*****************************************21*********************************//
@interface MyView21 : UIView
@end
@implementation MyView21
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx,1,0,0,1);//设置红色画笔
    CGContextMoveToPoint(ctx,110,0);
    CGContextAddLineToPoint(ctx,50,50);
    CGContextAddLineToPoint(ctx,80,10); //你可以去掉这一行和下面一行看看，就知道为什么我说的传入addArcToPoint方法里的参数本身不一定要绘制的原因了
    CGContextAddLineToPoint(ctx,50,50);
    CGContextAddArcToPoint(ctx,80,10,80,110,50);
    CGContextAddLineToPoint(ctx,80,110); //测试显示调用addArcToPoint结束后current point不在(80,110)上，而是在弧线结束的地方
    CGContextStrokePath(ctx);
}
@end
//*****************************************22*********************************//
@interface MyView22 : UIView
@end
@implementation MyView22
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx,1,0,0,1);//设置红色画笔
    CGContextMoveToPoint(ctx, 10, 10);
    CGContextAddCurveToPoint(ctx, 20, 20, 300, 40, 30, 20);
    CGContextStrokePath(ctx);
}
@end
//*****************************************23*********************************//
@interface MyView23 : UIView
@end
@implementation MyView23
- (void)drawRect:(CGRect)rect {
    [self drawingGradient];
}

- (void)drawTwoLines {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, screenRect.origin.x, screenRect.origin.y);
    CGPathAddLineToPoint(path, NULL, screenRect.size.width, screenRect.size.height);
    CGPathMoveToPoint(path, NULL, screenRect.size.width, screenRect.origin.y);
    CGPathAddLineToPoint(path, NULL, screenRect.origin.x, screenRect.size.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 1.0f);
    [[UIColor blueColor] setStroke];
    CGContextDrawPath(context, kCGPathStroke);      //第二个参数为画路径的样式，这里为描线，也可以有填充或者既描线也填充
    
    CGPathRelease(path);
}

- (void)drawTwoRects {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGRect rect1 = CGRectMake(20, 20, 200, 100);
    CGRect rect2 = CGRectMake(20, 200, 200, 80);
    CGRect rects[] = {rect1, rect2};
    
    CGPathAddRects(path, NULL, rects, 2);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, path);
    CGContextSetLineWidth(ctx, 2.0f);
    [[UIColor yellowColor] setFill];
    [[UIColor blackColor] setStroke];
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGPathRelease(path);
}

- (void)drawTwoRectsWithShadow {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGRect rect1 = CGRectMake(55, 60, 150, 150);
    CGPathAddRect(path, NULL, rect1);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, path);
    CGContextSetShadowWithColor(ctx, CGSizeMake(10, 10), 20.0f, [[UIColor grayColor] CGColor]);
    [[UIColor purpleColor] setFill];
    CGContextDrawPath(ctx, kCGPathFill);
    CGPathRelease(path);
    
    CGMutablePathRef path2 = CGPathCreateMutable();
    
    CGRect rect2 = CGRectMake(130, 290, 100, 100);
    CGPathAddRect(path2, NULL, rect2);
    CGContextAddPath(ctx, path2);
    [[UIColor yellowColor] setFill];
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGPathRelease(path2);
}

- (void)drawingGradient {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 (CGFloat[]){
                                                                     0.8, 0.2, 0.2, 1.0,
                                                                     0.2, 0.8, 0.2, 1.0,
                                                                     0.2, 0.2, 0.8, 1.0
                                                                 }, (CGFloat[]) {
                                                                     0.0, 0.5, 1.0
                                                                 }, 3);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(100, 200), CGPointMake(220, 280), kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(ctx);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}
@end
//*****************************************24*********************************//
@interface MyView24 : UIView
@end
@implementation MyView24
- (void)drawRect:(CGRect)rect {
    UIImage *logo = [UIImage imageNamed:@"about-logo"];
    CGRect bounds = CGRectMake(0, 0, logo.size.width, logo.size.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddEllipseInRect(path, NULL, bounds);
    CGPathAddEllipseInRect(path, NULL, CGRectMake(10, 10, logo.size.width - 20, logo.size.height - 20));
    CGPathAddEllipseInRect(path, NULL, CGRectMake(20, 20, logo.size.width - 40, logo.size.height - 40));
    CGContextAddPath(context, path);
    
    CGContextEOClip(context);
    [logo drawInRect:bounds];
    CFRelease(path);
}
@end
//*****************************************25*********************************//
@interface MyView25 : UIView
@end
@implementation MyView25
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddRect(ctx, CGRectMake(10, 10, 40, 70));
    CGContextAddRect(ctx, CGRectMake(20, 20, 50, 10));
    CGContextAddRect(ctx, CGRectMake(25, 25, 50, 5));
    CGContextEOFillPath(ctx);
    
    
    CGContextMoveToPoint(ctx, 50, 110);
    CGContextAddLineToPoint(ctx, 60, 130);
    CGContextAddLineToPoint(ctx, 70, 110);
    CGContextAddLineToPoint(ctx, 90, 160);
    CGContextAddLineToPoint(ctx, 0, 120);
    CGContextAddLineToPoint(ctx, 120, 120);
    CGContextAddLineToPoint(ctx, 30, 160);
    CGContextAddLineToPoint(ctx, 90, 160);
    CGContextClosePath(ctx);
    CGContextEOFillPath(ctx);
}


@end
//*****************************************26*********************************//
@interface MyView26 : UIView
@end
@implementation MyView26
- (void)drawRect:(CGRect)rect {
    CGRect bound = CGRectMake(0, 0, 300, 124);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0, 124);
        CGContextScaleCTM(context, 1.0, -1.0);
        [[UIColor blueColor] setFill];
        [@"我是你的好朋友" drawInRect:rect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:124]];
    CGContextRestoreGState(context);
    
    CGImageRef alphaMask = CGBitmapContextCreateImage(context);
    CGContextClipToMask(context, CGRectMake(0, 0, 100, 60), alphaMask);
    [[UIColor redColor] setFill];
    CGContextFillRect(context, bound);
    
    
//    [[UIImage imageNamed:@"about-logo"] drawInRect:rect];
    CGImageRelease(alphaMask);
}

@end
//*****************************************27*********************************//
@interface MyView27 : UIView

@end
@implementation MyView27
- (void)drawRect:(CGRect)rect {
    float wd = 300;
    float ht = 300;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize myShadowOffset = CGSizeMake(10, -20);
    CGContextSetShadow(ctx,  myShadowOffset, 10);
    CGContextBeginTransparencyLayer(ctx, NULL);
    CGContextSetRGBFillColor(ctx, 0, 1, 0, 1);
    CGContextFillRect(ctx, CGRectMake(wd / 3 + 50, ht / 2, wd / 4, ht / 4));
    CGContextSetRGBFillColor(ctx, 0, 0, 1, 1);
    CGContextFillRect(ctx, CGRectMake(wd / 3 - 50, ht / 2 - 100, wd / 4, ht / 4));
    CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
    CGContextFillRect(ctx, CGRectMake(wd / 3, ht / 2 - 50, wd / 4, ht / 4));
    CGContextEndTransparencyLayer(ctx);
    
    ht = 700;
    CGContextSetRGBFillColor(ctx, 0, 1, 0, 1);
    CGContextFillRect(ctx, CGRectMake(wd / 3 + 50, ht / 2, wd / 4, ht / 4));
    CGContextSetRGBFillColor(ctx, 0, 0, 1, 1);
    CGContextFillRect(ctx, CGRectMake(wd / 3 - 50, ht / 2 - 100, wd / 4, ht / 4));
    CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
    CGContextFillRect(ctx, CGRectMake(wd / 3, ht / 2 - 50, wd / 4, ht / 4));
}
@end
//*****************************************28*********************************//
@interface MyView28 : UIView

@end
@implementation MyView28
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIImage *currentImage = [UIImage imageNamed:@"comment_head"];
    CGImageRef image = CGImageRetain(currentImage.CGImage);
    CGRect imageRect = CGRectMake(0, 0, 10, 10);
    CGContextClipToRect(ctx, CGRectMake(0, 0, rect.size.width, rect.size.height));
    CGContextDrawTiledImage(ctx, imageRect, flip(image));
    
}
@end
//*****************************************29*********************************//
@interface MyView29 : UIView
@end
@implementation MyView29
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    //绘制渐变
//    CGFloat locs[3] = {0.0, 0.5, 1.0};
//    CGFloat colors[12] = {
//        0.3, 0.3, 0.3, 0.8,// 开始颜色，透明灰
//        0.0, 0.0, 0.0, 1.0,// 中间颜色，黑色
//        0.3, 0.3, 0.3, 0.8 // 末尾颜色，透明灰
//    };
//    CGColorSpaceRef sp = CGColorSpaceCreateDeviceGray();
//    CGGradientRef grad = CGGradientCreateWithColorComponents(sp, colors, locs, 3);
//    
//    
//    CGGradientRef myGradient;
//    CGColorSpaceRef myColorspace;
//    size_t num_locations = 2;
//    CGFloat locations[2] = { 0.0, 1.0 };
//    CGFloat components[8] = { 1.0, 0.5, 0.4, 1.0,  // Start color
//                              0.8, 0.8, 0.3, 1.0 }; // End color
//
//    myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
//    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
//                          locations, num_locations);
//
//    CGContextDrawLinearGradient(ctx, grad, CGPointMake(89, 0), CGPointMake(111, 0), 0);
//    CGContextDrawRadialGradient(ctx, myGradient, CGPointMake(100, 600), 20, CGPointMake(200, 300), 100, 0);
//    CGColorSpaceRelease(sp);
//    CGGradientRelease(grad);
    
    myPaintRadialShading(ctx, CGRectMake(50, 50, 250, 300));//myCalculateShadingValues1
//    myPaintAxialShading(ctx, CGRectMake(50, 250, 250, 300));//myCalculateShadingValues
}

static void myCalculateShadingValues(void *info, const CGFloat *in, CGFloat *out) {
    CGFloat v;
    size_t k, components;
    static const CGFloat c[] = {1, 0, .5, 0};
    components = (size_t)info;
    v = *in;
    for (k = 0; k < components - 1; k ++) {
        *out++ = c[k] * v;
    }
    *out++ = 1;
}

static void myCalculateShadingValues1(void *info, const CGFloat *in, CGFloat *out) {
    size_t k, components;
    double frequency[4] = {55, 220, 110, 0};
    components = (size_t)info;
    for (k = 0; k < components - 1; k ++) {
        *out++ = (1 +sin(*in * frequency[k]))/2;
    }
    *out++ = 1;//alpha
}

static CGFunctionRef myGetFunction(CGColorSpaceRef colorspace) {
    size_t numComponents;
    static const CGFloat input_value_range[2] = {0, 1};
    static const CGFloat output_value_ranges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
    static const CGFunctionCallbacks callbacks = {0, &myCalculateShadingValues1, NULL};
    numComponents = 1 + CGColorSpaceGetNumberOfComponents(colorspace);
    return CGFunctionCreate((void *)numComponents, 1, input_value_range, numComponents, output_value_ranges, &callbacks);
}


void myPaintAxialShading(CGContextRef myContext, CGRect bounds) {
    CGPoint startPoint = CGPointMake(0, 0.5), endPoint = CGPointMake(1, .5);
    CGFloat width = bounds.size.width, height = bounds.size.height;
    CGAffineTransform myTransform = CGAffineTransformMakeScale(width, height);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFunctionRef myShadingFunction = myGetFunction(colorspace);
    
    CGShadingRef shading = CGShadingCreateAxial(colorspace, startPoint, endPoint, myShadingFunction, false, false);
    CGContextConcatCTM(myContext, myTransform);
    CGContextSaveGState(myContext);
    
    CGContextClipToRect(myContext, CGRectMake(0, 0, 1, 1));
    CGContextSetRGBFillColor(myContext, 1, 1, 1, 1);
    CGContextFillRect(myContext, CGRectMake(0, 0, 1, 1));
    
    CGContextBeginPath(myContext);
    CGContextAddArc(myContext, .5, .5, .3, 0, M_PI, 0);
    CGContextClosePath(myContext);
    CGContextClip(myContext);
    
    CGContextDrawShading(myContext, shading);
    CGColorSpaceRelease(colorspace);
    CGShadingRelease(shading);
    CGFunctionRelease(myShadingFunction);
    
    CGContextRestoreGState(myContext);
    
}

void myPaintRadialShading(CGContextRef myContext, CGRect bounds) {
    CGPoint startPoint = CGPointMake(0.25, 0.3), endPoint = CGPointMake(.7, .7);
    CGFloat startRadius = .1, endRadius = .25;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    CGAffineTransform mytrasnform = CGAffineTransformMakeScale(width, height);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFunctionRef myShadingFunction = myGetFunction(colorspace);
    CGShadingRef shading = CGShadingCreateRadial(colorspace, startPoint, startRadius, endPoint, endRadius, myShadingFunction, false, false);
    CGContextConcatCTM(myContext, mytrasnform);
    CGContextSaveGState(myContext);
    CGContextClipToRect(myContext, CGRectMake(0, 0, 1, 1));
    CGContextSetRGBFillColor(myContext, 1, 1, 1, 1);
    CGContextFillRect(myContext, CGRectMake(0, 0, 1, 1));
    CGContextDrawShading(myContext, shading);
    CGColorSpaceRelease(colorspace);
    CGShadingRelease(shading);
    CGFunctionRelease(myShadingFunction);
    CGContextRestoreGState(myContext);
}

@end
//*****************************************29*********************************//
@interface MyView30 : UIView
@end
@implementation MyView30
- (void)drawRect:(CGRect)rect {
//    CGRect myBoundingBox = CGRectMake(0, 0, m, <#CGFloat height#>)
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh) {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    int bitmapBytesPerRow = (pixelsWide * 4);
    int bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    void *bitmapData = calloc(bitmapByteCount, 0);
    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocated!");
        return NULL;
    }
    context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    if (context == NULL) {
        free(bitmapData);
        fprintf(stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease(colorSpace);
    return context;
}

@end

#define PSIZE 16 //size of the pattern cell
@interface MyView31 : UIView
@end
@implementation MyView31
- (void)drawRect:(CGRect)rect {
    MyStencilPatternPainting(UIGraphicsGetCurrentContext(), NULL);
}

static void MyDrawStencilStar (void *info, CGContextRef myContext) {
    int k;
    double r, theta;
    
    r = 0.8 *PSIZE / 2;
    theta = 2 * M_PI * (2.0 / 5.0); // 144 degrees
    
    CGContextTranslateCTM(myContext, PSIZE/2, PSIZE/2);
    
    CGContextMoveToPoint(myContext, 0, r);
    for (k = 1; k < 5; k ++) {
        CGContextAddLineToPoint(myContext, r * sin(k * theta), r * cos(k * theta));
    }
    CGContextClosePath(myContext);
    CGContextFillPath(myContext);
}

void MyStencilPatternPainting(CGContextRef myContext, const Rect *windowRect) {
    CGPatternRef pattern;
    CGColorSpaceRef baseSpace;
    CGColorSpaceRef patternSpace;
    static const CGFloat color[4] = {0, 1, 0, 1};
    static const CGPatternCallbacks callbacks = {0, &MyDrawStencilStar, NULL};
    //创建一个通用RGB颜色空间。
    baseSpace = CGColorSpaceCreateDeviceRGB();
    //创建一个模式颜色空间。该颜色空间指定如何表示模式的颜色。后面要设置模式的颜色时，必须使用这个颜色空间来进行设置
    patternSpace = CGColorSpaceCreatePattern(baseSpace);
    //设置颜色空间来在填充模式时使用
    CGContextSetFillColorSpace(myContext, patternSpace);
    //释放模式颜色空间
    CGColorSpaceRelease(patternSpace);
    //释放基础颜色空间
    CGColorSpaceRelease(baseSpace);
    pattern = CGPatternCreate(NULL, CGRectMake(0, 0, PSIZE, PSIZE), CGAffineTransformIdentity, PSIZE, PSIZE, kCGPatternTilingConstantSpacing, false, &callbacks);
    CGContextSetFillPattern(myContext, pattern, color);
    CGPatternRelease(pattern);
    CGContextFillRect(myContext, CGRectMake(0, 0, PSIZE*20, PSIZE*20));
}
@end

/**
 * 1.红色条纹和白色条纹的模式。我们可以将这个模式分解为一个单一的红色条纹，因为对于屏幕绘制来说，我们可以假设其背景颜色为白色。我们创建一个红色矩形，然后以变化的偏移量来重复绘制这个矩形，以创建美国国旗上的七条红色条纹。我们将红色矩形绘制到一个层，然后将其绘制到屏幕上七次。
 * 2.一个蓝色矩形。我们只需要一个蓝色矩形，所以没有必要使用层。当绘制蓝色矩形时，直接将其绘制到屏幕上。
 * 3.50个白色星星的模式。与红色条纹一下，可以使用层来绘制星星。我们创建星星边框的一个路径，然后使用白条来填充。将一个星星绘制到层，然后重复50次绘制这个层，每次绘制时适当调整偏移量。
 * 
 * 代码清单12-2完成了对图12-5的绘制。myDrawFlag例程在一个Cocoa程序中调用。这个程序传递一个window图形上下文和一个与图形上下文相关的视图的大小。
**/
@interface MyView32 : UIView
@end
@implementation MyView32
- (void)drawRect:(CGRect)rect {
    CGRect rect1 = CGRectMake(0, 0, 300, 300);
    myDrawFlag(UIGraphicsGetCurrentContext(), &rect1);
}

void myDrawFlag (CGContextRef context, CGRect *contextRect) {
    int i, j, num_six_star_rows = 5, num_five_star_rows = 4;
    //第一个星星的横坐标
    CGFloat start_x = 5.0,
    //第一个星星的纵坐标
            start_y = 108.0,
    //红线之间的间距
            red_stripe_spacing = 34.0,
    //红旗上星星的横向间距
            h_spacing = 26.0,
    //红旗上星星的纵向间距
            v_spacing = 22.0;
    
    CGContextRef myLayerContext1, myLayerContext2;
    CGLayerRef stripeLayer, starLayer;
    //指定旗的绘画区域，条纹区域，星星区域
    CGRect myBoundingBox, stripeRect, starField;
    //********Setting up the primitives *********//
    //Declares an array of points that specify the lines that trace out one star.
    CGPoint point1 = {5, 5}, point2 = {10, 15}, point3 = {10, 15}, point4 = {15, 5};
    CGPoint point5 = {15, 5}, point6 = {2.5, 11}, point7 = {2.5, 11}, point8 = {16.5, 11};
    CGPoint point9 = {16.5, 11}, point10 = {5, 5};
    const CGPoint myStarPoints[] = {point1, point2, point3, point4, point5, point6, point7, point8, point9, point10};
    stripeRect = CGRectMake(0, 0, 400, 17); // stripe
    starField = CGRectMake(0, 102, 160, 119); // star field
    myBoundingBox = CGRectMake(0, 0, contextRect->size.width, contextRect->size.height);
    //***Creating layers and drawing to them ******
    stripeLayer = CGLayerCreateWithContext(context, stripeRect.size, NULL);
    myLayerContext1 = CGLayerGetContext(stripeLayer);
    
    CGContextSetRGBFillColor(myLayerContext1, 1, 0, 0, 1);
    CGContextFillRect(myLayerContext1, stripeRect);
    
    starLayer = CGLayerCreateWithContext(context, starField.size, NULL);
    myLayerContext2 = CGLayerGetContext(starLayer);
    CGContextSetRGBFillColor(myLayerContext2, 1.0, 1.0, 1.0, 1);
    CGContextAddLines(myLayerContext2, myStarPoints, 10);
    CGContextFillPath(myLayerContext2);
    
    //****** Drawing to the window graphics context *****
    CGContextSaveGState(context);
    for (i = 0; i < 7; i ++) {
        CGContextDrawLayerAtPoint(context, CGPointZero, stripeLayer);
        CGContextTranslateCTM(context, 0.0, red_stripe_spacing);
    }
    CGContextRestoreGState(context);
    
    CGContextSetRGBFillColor(context, 0, 0, 0.329, 1.0);
    CGContextFillRect(context, starField);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, start_x, start_y);
    for (j = 0; j < num_six_star_rows; j ++) {
        for (i = 0; i < 6; i ++) {
            CGContextDrawLayerAtPoint(context, CGPointZero, starLayer);
            CGContextTranslateCTM(context, h_spacing, 0);
        }
        CGContextTranslateCTM(context, (-i*h_spacing), v_spacing);
    }
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, start_x + h_spacing / 2, start_y + v_spacing / 2);
    for (j = 0; j < num_five_star_rows; j ++) {
        for (i = 0; i < 5; i ++) {
            CGContextDrawLayerAtPoint(context, CGPointZero, starLayer);
            CGContextTranslateCTM(context, h_spacing, 0);
        }
        CGContextTranslateCTM(context, (-i*h_spacing), v_spacing);
    }
    CGContextRestoreGState(context);
    
    CGLayerRelease(stripeLayer);
    CGLayerRelease(starLayer);
}

@end


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIView *view = [[NSClassFromString(self.loadViewClass) alloc] init];
    if (!view) {
        return;
    }
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(20, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    [self.view addSubview:view];
    self.view.backgroundColor = [UIColor grayColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
