//
//  NEGesturePasswordView.h
//  SuiXinZT
//
//  Created by yongjing.xiao on 2017/6/16.
//  Copyright © 2017年 xinweilai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NEGesturePasswordView;

@protocol NEGesturePasswordDelegate <NSObject>

@optional
//手势密码
- (void)NEGestureLockSetResult:(NSString *)result gestureView:(GesturePasswordView *)gestureView;
//底部按钮的点击事件
- (void)bottomButtonClickWithText:(NSString *)buttonText;


@end

@interface NEGesturePasswordView : UIView

@property (nonatomic ,copy)NSString *bottomBtnText;

//顶部显示的文字
@property (nonatomic,copy)NSString *title;

@property (assign, nonatomic) id<NEGesturePasswordDelegate> delegate;

//效验错误
-(void)checkOutWrongWithMessage:(NSString *)message;
//效验正确
-(void)checkOutRight;

@end
