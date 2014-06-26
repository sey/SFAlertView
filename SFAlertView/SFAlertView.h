//
//  SFAlertView.h
//  SFAlertView
//
//  Created by Florian Sey on 20/01/2014.
//  Copyright (c) 2014 Florian Sey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAlertView;

/**
 *  Handler for buttons added to the alert view.
 *  Each button can have its own handler.
 *
 *  @param alertView the alert view that owns the button on which the action was triggered.
 */
typedef void(^SFAlertViewHandler)(SFAlertView *alertView);

/**
 *  These constants specify the type of button that can be used.
 */
typedef NS_ENUM(NSInteger, SFAlertViewButtonType) {
    /**
     *  The default type represents a button with no particular semantic. The button will be created using the default button color and text color specified on the alert view.
     */
    SFAlertViewButtonTypeDefault = 0,
    /**
     *  The destructive type represents a button that trigger a destructive action. It uses the destructive button color.
     */
    SFAlertViewButtonTypeDestructive,
    /**
     *  The cancel type represents a button that cancel the underlying action that the alert view presented.
     */
    SFAlertViewButtonTypeCancel
};

/**
 *  These constants specify the different kind of background an alert view window can have.
 */
typedef NS_ENUM(NSInteger, SFAlertViewBackgroundStyle) {
    /**
     *  The window will have a radial transparent to semi-transparent black gradient background.
     */
    SFAlertViewBackgroundStyleGradient = 0,
    /**
     *  The window will have a semi-transparent background.
     */
    SFAlertViewBackgroundStyleSolid,
};

/**
 *  These constants specify the different style of an alert view.
 */
typedef NS_ENUM(NSInteger, SFAlertViewStyle)
{
    /**
     *  This is the easiest style to use with the alert view.
     *  It allows the alert view to have a title, a message and buttons.
     */
    SFAlertViewStyleAlertView,
    /**
     *  This is the default style of an alert view.
     *  The popup style allows the alert view to have a custom content which the alert view will wrap.
     *  With this style the alert view can also have a bar with a close button and a title, and buttons under the content view.
     */
    SFAlertViewStylePopup
};

/**
 *  The SFAlertView class is a custom alert view with a content hugging feature at its core.
 *  This means the alert view will resize in height depending on its content.
 */
@interface SFAlertView : UIView

/**
 *  The title of the alert view.
 */
@property (nonatomic, copy) NSString *title;

/**
 *  The message of the alert view.
 */
@property (nonatomic, copy) NSString *message;

/**
 *  The style of the alert view.
 */
@property (nonatomic, readonly) SFAlertViewStyle alertViewStyle;

@property (nonatomic, copy) SFAlertViewHandler willShowHandler;
@property (nonatomic, copy) SFAlertViewHandler didShowHandler;
@property (nonatomic, copy) SFAlertViewHandler willDismissHandler;
@property (nonatomic, copy) SFAlertViewHandler didDismissHandler;

/**
 *  The alert view preferred width. Should be set so the alert view can properly size its subviews.
 *  This property can be set globally through the alert view UIAppearance proxy.
 */
@property (nonatomic, assign) CGFloat alertViewPreferredWidth UI_APPEARANCE_SELECTOR;

/**
 *  The preferred width for the buttons if any.
 */
@property (nonatomic, assign) CGFloat buttonsPreferredWidth UI_APPEARANCE_SELECTOR;

/**
 *  The background color of the close button.
 */
@property (nonatomic, strong) UIColor *closeButtonBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 *  The default buttons color.
 */
@property (nonatomic, strong) UIColor *buttonColor UI_APPEARANCE_SELECTOR;

/**
 *  The cancel buttons color.
 */
@property (nonatomic, strong) UIColor *cancelButtonColor UI_APPEARANCE_SELECTOR;

/**
 *  The destructive buttons color.
 */
@property (nonatomic, strong) UIColor *destructiveButtonColor UI_APPEARANCE_SELECTOR;

/**
 *  The separator color of the view between the title bar and the container view.
 */
@property (nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

/**
 *  The title label font.
 */
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;

/**
 *  The message label font.
 */
@property (nonatomic, strong) UIFont *messageFont UI_APPEARANCE_SELECTOR;

/**
 *  The title label color.
 */
@property (nonatomic, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;

/**
 *  The message label color.
 */
@property (nonatomic, strong) UIColor *messageColor UI_APPEARANCE_SELECTOR;

/**
 *  Whether the alert view is visible or not.
 */
@property (nonatomic, readonly, getter = isVisible) BOOL visible;

/**
 *  Whether the alert view close button should be hidden or not.
 *  This is only useful for the SFAlertViewStylePopup style.
 */
@property (nonatomic, assign) BOOL hideCloseButton;

/**
 *  Initialize an alert view with the specified title and message.
 *  The alert view will be initialized with the SFAlertViewStyleAlertView style.
 *
 *  @param title   the title for the alert view's title bar, passing nil will hide the title bar.
 *  @param message the message.
 *
 *  @return an initialized alert view object or nil if the object couldn't be created.
 */
- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message;

/**
 *  Add a button with its title, type and handler.
 *
 *  @param title   the button's title.
 *  @param type    the button's type (see SFAlertViewButtonType).
 *  @param handler the handler.
 */
- (void)addButtonWithTitle:(NSString *)title
                      type:(SFAlertViewButtonType)type
                   handler:(SFAlertViewHandler)handler;

/**
 *  Add a button with its title, type and handler.
 *
 *  @param title   the button's title.
 *  @param image   the button's image.
 *  @param type    the button's type (see SFAlertViewButtonType).
 *  @param handler the handler.
 */
- (void)addButtonWithTitle:(NSString *)title
                     image:(UIImage *)image
                      type:(SFAlertViewButtonType)type
                   handler:(SFAlertViewHandler)handler;

/**
 *  Set the content view for the alert view.
 *  This method should only be used for alert view with the SFAlertViewStylePopup style.
 *
 *  @param view the view to set. The view should set it's width with autolayout constraint.
 */
- (void)setContentView:(UIView *)view;

/**
 *  Set the content view controller for the alert view.
 *  This retains the viewController and set its view as the content view.
 *  If you need control on the content view you should create a controller and use this method to configure the alert view.
 *
 *  @param viewController the view controller that owns the content view.
 */
- (void)setContentViewController:(UIViewController *)viewController;

/**
 *  Show the alert view.
 *  If another alert view is displayed it will be dismissed and queued to be displayed after this one is dismissed.
 */
- (void)show;

/**
 *  Dismiss the alert view.
 *
 *  @param animated whether the dismiss action should be animated or not.
 */
- (void)dismissAnimated:(BOOL)animated;

/**
 *  Set the close button image.
 *
 *  @param defaultButtonImage the image.
 *  @param state              the button's state.
 */
- (void)setCloseButtonImage:(UIImage *)defaultButtonImage
                   forState:(UIControlState)state UI_APPEARANCE_SELECTOR;

/**
 *  Dismiss the currently presented popup if any.
 *  Clean the popup queue.
 */
+ (void)cleanPopup;

@end

/**
 *  UIViewController category to give access to the alert view 
 *  when configuring the alert view with setContentViewController:.
 */
@interface UIViewController (SFAlertView)

/**
 *  The alert view. Can be nil if the controller is not in an alert view.
 */
@property (nonatomic, readonly, strong) SFAlertView *alertView;

@end
