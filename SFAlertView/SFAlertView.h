//
//  SFAlertView.h
//  SFAlertView
//
//  Created by Florian Sey on 20/01/2014.
//  Copyright (c) 2014 Florian Sey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAlertView;
typedef void(^SFAlertViewHandler)(SFAlertView *alertView);

typedef NS_ENUM(NSInteger, SFAlertViewButtonType) {
    SFAlertViewButtonTypeDefault = 0,
    SFAlertViewButtonTypeDestructive,
    SFAlertViewButtonTypeCancel
};

typedef NS_ENUM(NSInteger, SFAlertViewBackgroundStyle) {
    SFAlertViewBackgroundStyleGradient = 0,
    SFAlertViewBackgroundStyleSolid,
};

@interface SFAlertView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, assign) CGFloat alertViewPreferredWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat buttonsPreferredWidth UI_APPEARANCE_SELECTOR;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;


@property (nonatomic, strong) UIColor *closeButtonBackgroundColor UI_APPEARANCE_SELECTOR;


- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message;
- (void)addButtonWithTitle:(NSString *)title
                      type:(SFAlertViewButtonType)type
                   handler:(SFAlertViewHandler)handler;

- (void)setContentView:(UIView *)view;
- (void)setContentViewController:(UIViewController *)viewController;

- (void)show;
- (void)dismissAnimated:(BOOL)animated;

@end