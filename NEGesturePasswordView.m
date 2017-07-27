//
//  NEGesturePasswordView.m
//  SuiXinZT
//
//  Created by yongjing.xiao on 2017/6/16.
//  Copyright © 2017年 xinweilai. All rights reserved.
//

#import "NEGesturePasswordView.h"

//#define SELECT_COLOR [UIColor colorWithRed:0.3 green:0.7 blue:1 alpha:1]

@interface NEGesturePasswordView()

@property (strong, nonatomic) NSMutableArray *selectBtnArr;
@property (assign, nonatomic) CGPoint currentPoint;
//标题文字label
@property (weak, nonatomic) UILabel *label;
//提示文字label
@property (weak, nonatomic) UILabel *attentionLabel;
//底部的按钮
@property (nonatomic ,strong)UIButton *bottomButton;

@end

@implementation NEGesturePasswordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectBtnArr = [[NSMutableArray alloc]initWithCapacity:0];
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviewsWithFrame:frame];
        
    }
    return self;
}

-(void)setupSubviewsWithFrame:(CGRect)frame{
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    //文字框
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, width, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = FONT_14;
    [self addSubview:label];
    _label = label;
    
    //至少连接4个点
    UILabel *attentionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom, width, 30)];
    attentionLabel.textAlignment = NSTextAlignmentCenter;
    attentionLabel.textColor = BUTTONBACKCOLOR;
    attentionLabel.font = FONT_12;
    attentionLabel.text = @"*至少连接4个点";
    [self addSubview:attentionLabel];
    _attentionLabel = attentionLabel;
    
    
    float interval = width/7;
    for (int i = 0; i < 9; i ++) {
        int row = i/3;
        int list = i%3;
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(list*(interval+interval)+interval, row*(interval+interval)+interval + attentionLabel.bottom + 20, interval, interval)];
        btn.userInteractionEnabled = NO;
        [btn setImage:[self drawUnselectImageWithRadius:interval-6] forState:UIControlStateNormal];
        [btn setImage:[self drawSelectImageWithRadius:interval-6] forState:UIControlStateSelected];
        [self addSubview:btn];
        btn.tag = i + 1;
    }
    
    UIButton *bottomBtn = [[UIButton alloc]init];
    bottomBtn.centerX = width/2;
    bottomBtn.centerY = height - 20;
    bottomBtn.bounds = CGRectMake(0, 0, 200, 40);
    [bottomBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    bottomBtn.titleLabel.font = FONT_14;
    [self addSubview:bottomBtn];
    _bottomButton = bottomBtn;
}

-(void)setBottomBtnText:(NSString *)bottomBtnText{
    _bottomBtnText = bottomBtnText;
    [_bottomButton setTitle:bottomBtnText forState:UIControlStateNormal];
    [_bottomButton addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark --- 底部按钮的点击事件
-(void)bottomBtnClick:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(bottomButtonClickWithText:)]) {
        [self.delegate bottomButtonClickWithText:sender.titleLabel.text];
    }
}

-(void)setTitle:(NSString *)title{
    _title = title;
    _label.text = title;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path;
    if (_selectBtnArr.count == 0) {
        return;
    }
    path = [UIBezierPath bezierPath];
    path.lineWidth = 5;
    path.lineJoinStyle = kCGLineCapRound;
    path.lineCapStyle = kCGLineCapRound;
    if (self.userInteractionEnabled) {
        [SYSTEMCOLOR set];
    }else
    {
        [BUTTONBACKCOLOR set];
    }
    for (int i = 0; i < _selectBtnArr.count; i ++) {
        UIButton *btn = _selectBtnArr[i];
        if (i == 0) {
            [path moveToPoint:btn.center];
        }else
        {
            [path addLineToPoint:btn.center];
        }
    }
    [path addLineToPoint:_currentPoint];
    [path stroke];
    
}


//视图恢复原样
- (void)resetView
{
    for (UIButton *oneSelectBtn in _selectBtnArr) {
        oneSelectBtn.selected = NO;
    }
    [_selectBtnArr removeAllObjects];
    [self setNeedsDisplay];
}

//输入错误回到原状态
- (void)wrongRevert:(NSArray *)arr
{
    self.userInteractionEnabled = YES;
    for (UIButton *btn in arr) {
        float interval = self.frame.size.width/7;
        [btn setImage:[self drawSelectImageWithRadius:interval-6] forState:UIControlStateSelected];
    }
    [self resetView];
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *oneTouch = [touches anyObject];
    CGPoint point = [oneTouch locationInView:self];
    
    for (int i = 1; i <= 9; i++) {
        UIButton *oneBtn = [self viewWithTag:i];
        if (CGRectContainsPoint(oneBtn.frame, point)) {
            oneBtn.selected = YES;
            if (![_selectBtnArr containsObject:oneBtn]) {
                [_selectBtnArr addObject:oneBtn];
            }
        }
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *oneTouch = [touches anyObject];
    CGPoint point = [oneTouch locationInView:self];
    _currentPoint = point;
    for (int i = 1; i <= 9; i++) {
        UIButton *oneBtn = [self viewWithTag:i];
        if (CGRectContainsPoint(oneBtn.frame, point)) {
            oneBtn.selected = YES;
            if (![_selectBtnArr containsObject:oneBtn]) {
                [_selectBtnArr addObject:oneBtn];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //获取结果
    NSMutableString *result = [[NSMutableString alloc]initWithCapacity:0];
    for (int i = 0; i < _selectBtnArr.count; i ++) {
        UIButton *btn = (UIButton *)_selectBtnArr[i];
        [result appendFormat:@"%d",(int)btn.tag];
    }
    if (result.length < 4) {
        if (result.length == 0) {
            return;
        }
        _attentionLabel.text = @"*至少连接4个点，请重试";
        [self resetView];
        return;
    }
    result = [NSMutableString stringWithString:[result SHA512]];//加密
    
    UIButton *lastBtn = [_selectBtnArr lastObject];
    _currentPoint = lastBtn.center;
    
    
    [self.delegate GestureLockSetResult:result gestureView:self];

    
}

//效验错误
-(void)checkOutWrongWithMessage:(NSString *)message{
    _attentionLabel.text = message;
    for (UIButton *btn in _selectBtnArr) {
        float interval = self.frame.size.width/7;
        [btn setImage:[self drawWrongImageWithRadius:interval-6] forState:UIControlStateSelected];
    }
    [self performSelector:@selector(wrongRevert:) withObject:[NSArray arrayWithArray:_selectBtnArr] afterDelay:1];
    self.userInteractionEnabled = NO;
    [self setNeedsDisplay];
}

-(void)checkOutRight;{
    [self resetView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - CGContext使用
//画未选中点图片
- (UIImage *)drawUnselectImageWithRadius:(float)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] setStroke];
    CGContextSetLineWidth(context, 3);
    
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *unselectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return unselectImage;
}

//画选中点图片
- (UIImage *)drawSelectImageWithRadius:(float)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 3);
    
    CGContextAddEllipseInRect(context, CGRectMake(3+radius*5/12, 3+radius*5/12, radius/6, radius/6));
    
    UIColor *selectColor = SYSTEMCOLOR;
    
    [selectColor set];
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
    
    [selectColor setStroke];
    
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

//画错误图片
- (UIImage *)drawWrongImageWithRadius:(float)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 5);
    
    CGContextAddEllipseInRect(context, CGRectMake(3+radius*5/12, 3+radius*5/12, radius/6, radius/6));
    
    UIColor *selectColor = BUTTONBACKCOLOR;
    
    [selectColor set];
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
    
    [selectColor setStroke];
    
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


@end
