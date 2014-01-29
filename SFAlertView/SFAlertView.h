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

typedef NS_ENUM(NSInteger, SFAlertViewStyle)
{
    SFAlertViewStyleAlertView,
    SFAlertViewStylePopup
};

@interface SFAlertView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) SFAlertViewStyle alertViewStyle;

@property (nonatomic, copy) SFAlertViewHandler willShowHandler;
@property (nonatomic, copy) SFAlertViewHandler didShowHandler;
@property (nonatomic, copy) SFAlertViewHandler willDismissHandler;
@property (nonatomic, copy) SFAlertViewHandler didDismissHandler;

@property (nonatomic, assign) CGFloat alertViewPreferredWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat buttonsPreferredWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *closeButtonBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *buttonColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cancelButtonColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *destructiveButtonColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *messageFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *messageColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;
@property (nonatomic, assign) BOOL hideCloseButton;

- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message;
- (void)addButtonWithTitle:(NSString *)title
                      type:(SFAlertViewButtonType)type
                   handler:(SFAlertViewHandler)handler;
- (void)addButtonWithTitle:(NSString *)title
                     image:(UIImage *)image
                      type:(SFAlertViewButtonType)type
                   handler:(SFAlertViewHandler)handler;

- (void)setContentView:(UIView *)view;
- (void)setContentViewController:(UIViewController *)viewController;

- (void)show;
- (void)dismissAnimated:(BOOL)animated;


- (void)setCloseButtonImage:(UIImage *)defaultButtonImage
                   forState:(UIControlState)state UI_APPEARANCE_SELECTOR;

+ (void)cleanPopup;

@end

@interface UIViewController (SFAlertView)

@property (nonatomic, readonly, strong) SFAlertView *alertView;

@end
