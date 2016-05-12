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
    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
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
///
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
        CGPatternRef patt = CGPatternCreate(&buf, CGRectMake(0, 0, 4, 4), tr, 4, 4, kCGPatternTilingConstantSpacingMinimalDistortion, true, &callback);
        CGFloat alph = 1.0;
        CGContextSetPatternPhase(ctx, CGSizeMake(40, 25));//CGContextSetPatternPhase函数改变模板的定位,不用这个最底部的似乎只平铺了一半蓝色。这是因为一个模板的定位并不关心你填充（描边）的形状，总的来说它只关心图形上下文。
        CGContextSetFillPattern(ctx, patt, &alph);
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
