//
//  SFAlertView.m
//  SFAlertView
//
//  Created by Florian Sey on 20/01/2014.
//  Copyright (c) 2014 Florian Sey. All rights reserved.
//

#import "SFAlertView.h"
#import "UIWindow+SIUtils.h"
#import "UIView+Autolayout.h"

const UIWindowLevel UIWindowLevelSFAlert = 1999.0;  // don't overlap system's alert
const UIWindowLevel UIWindowLevelSFAlertBackground = 1998.0; // below the alert window

@class SFAlertBackgroundWindow;

static NSMutableArray *__sf_alert_queue;
static BOOL __sf_alert_animating;
static SFAlertBackgroundWindow *__sf_alert_background_window;
static SFAlertView *__sf_alert_current_view;

@interface SFAlertView ()

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, weak) UIWindow *oldKeyWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
#ifdef __IPHONE_7_0
@property (nonatomic, assign) UIViewTintAdjustmentMode oldTintAdjustmentMode;
#endif

@property (nonatomic, assign, getter = isVisible) BOOL visible;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *buttonsContainerView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, strong) NSMutableArray *buttons;

+ (NSMutableArray *)sharedQueue;
+ (SFAlertView *)currentAlertView;

- (void)setup;

@end

#pragma mark - SFAlertBackgroundWindow

@interface SFAlertBackgroundWindow : UIWindow

@end

@interface SFAlertBackgroundWindow ()

@property (nonatomic, assign) SFAlertViewBackgroundStyle style;

@end

@implementation SFAlertBackgroundWindow

- (id)initWithFrame:(CGRect)frame
           andStyle:(SFAlertViewBackgroundStyle)style
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.style = style;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = UIWindowLevelSFAlertBackground;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.style)
    {
        case SFAlertViewBackgroundStyleGradient:
        {
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
            CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            break;
        }
        case SFAlertViewBackgroundStyleSolid:
        {
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
    }
}

@end

#pragma mark - SFAlertViewController

@interface SFAlertViewController : UIViewController

@property (nonatomic, strong) SFAlertView *alertView;

@end

@implementation SFAlertViewController

#pragma mark - UIViewController Lifecycle Methods

- (void)loadView
{
    // create the root view
    self.view = [UIView new];
    
    // add the alert view to the controller view hierarchy
    [self.view addSubview:self.alertView];
    
    // set constraints to center the alert view horizontally and vertically
    [self.alertView autoCenterInSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.alertView setup];
}

#ifdef __IPHONE_7_0
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}
#endif

- (NSUInteger)supportedInterfaceOrientations
{
    UIViewController *viewController = [self.alertView.oldKeyWindow currentViewController];
    if (viewController)
    {
        NSLog(@"UIInterfaceOrientationMaskPortrait: %d", UIInterfaceOrientationMaskPortrait);
        NSLog(@"UIInterfaceOrientationMaskLandscapeLeft: %d", UIInterfaceOrientationMaskLandscapeLeft);
        NSLog(@"UIInterfaceOrientationMaskLandscapeRight: %d", UIInterfaceOrientationMaskLandscapeRight);
        NSLog(@"UIInterfaceOrientationMaskPortraitUpsideDown: %d", UIInterfaceOrientationMaskPortraitUpsideDown);
        NSLog(@"UIInterfaceOrientationMaskLandscape: %d", UIInterfaceOrientationMaskLandscape);
        NSLog(@"UIInterfaceOrientationMaskAll: %d", UIInterfaceOrientationMaskAll);
        NSLog(@"UIInterfaceOrientationMaskAllButUpsideDown: %d", UIInterfaceOrientationMaskAllButUpsideDown);
        return [viewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIViewController *viewController = [self.alertView.oldKeyWindow currentViewController];
    if (viewController)
    {
        return [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    return YES;
}

- (BOOL)shouldAutorotate
{
    UIViewController *viewController = [self.alertView.oldKeyWindow currentViewController];
    if (viewController)
    {
        return [viewController shouldAutorotate];
    }
    return YES;
}

#ifdef __IPHONE_7_0
- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIWindow *window = self.alertView.oldKeyWindow;
    if (!window)
    {
        window = [UIApplication sharedApplication].windows[0];
    }
    return [[window viewControllerForStatusBarStyle] preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    UIWindow *window = self.alertView.oldKeyWindow;
    if (!window)
    {
        window = [UIApplication sharedApplication].windows[0];
    }
    return [[window viewControllerForStatusBarHidden] prefersStatusBarHidden];
}
#endif

@end

#pragma mark - SIAlertItem

@interface SFAlertItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SFAlertViewButtonType type;
@property (nonatomic, copy) SFAlertViewHandler action;

@end

@implementation SFAlertItem

@end

#pragma mark - SIAlertView

@implementation SFAlertView

#pragma mark - Class Methods

+ (NSMutableArray *)sharedQueue
{
    if (!__sf_alert_queue) {
        __sf_alert_queue = [NSMutableArray array];
    }
    return __sf_alert_queue;
}

+ (SFAlertView *)currentAlertView
{
    return __sf_alert_current_view;
}

+ (void)setCurrentAlertView:(SFAlertView *)alertView
{
    __sf_alert_current_view = alertView;
}

+ (BOOL)isAnimating
{
    return __sf_alert_animating;
}

+ (void)setAnimating:(BOOL)animating
{
    __sf_alert_animating = animating;
}

+ (void)showBackground
{
    if (!__sf_alert_background_window)
    {
        __sf_alert_background_window = [[SFAlertBackgroundWindow alloc]
                                        initWithFrame:[UIScreen mainScreen].bounds
                                        andStyle:SFAlertViewBackgroundStyleGradient];
        [__sf_alert_background_window makeKeyAndVisible];
        __sf_alert_background_window.alpha = 0;
        [UIView
         animateWithDuration:0.3f
         animations:^
        {
            __sf_alert_background_window.alpha = 1;
        }];
    }
}

+ (void)hideBackgroundAnimated:(BOOL)animated
{
    if (!animated)
    {
        [__sf_alert_background_window removeFromSuperview];
        __sf_alert_background_window = nil;
        return;
    }
    [UIView
     animateWithDuration:0.3
     animations:^
    {
        __sf_alert_background_window.alpha = 0;
    }
     completion:^(BOOL finished)
    {
        [__sf_alert_background_window removeFromSuperview];
        __sf_alert_background_window = nil;
    }];
}

#pragma mark - Custom Getter & Setter Methods

- (NSMutableArray *)items
{
    if (!_items)
    {
        _items = [NSMutableArray new];
    }
    return _items;
}

#pragma mark - Public Methods

+ (void)initialize
{
    if (self != [SFAlertView class])
        return;
    
    SFAlertView *appearance = [self appearance];
    appearance.closeButtonBackgroundColor = [UIColor redColor];
    appearance.buttonColor = [UIColor greenColor];
    appearance.cancelButtonColor = [UIColor blackColor];
    appearance.destructiveButtonColor = [UIColor redColor];
    appearance.separatorColor = [UIColor grayColor];
    appearance.alertViewPreferredWidth = 450.0f;
    appearance.buttonsPreferredWidth = 150.0f;
}

+ (void)cleanPopup
{
    NSMutableIndexSet *alertToDeleteIndexes = [NSMutableIndexSet new];
    for (NSUInteger i = 0; i < [SFAlertView sharedQueue].count; i++)
    {
        SFAlertView *alertView = [SFAlertView sharedQueue][i];
        if (alertView.alertViewStyle == SFAlertViewStylePopup && !alertView.isVisible)
        {
            [alertToDeleteIndexes addIndex:i];
        }
    }
    [[SFAlertView sharedQueue] removeObjectsAtIndexes:alertToDeleteIndexes];
    
    if ([SFAlertView currentAlertView].alertViewStyle == SFAlertViewStylePopup)
    {
        [[SFAlertView currentAlertView] dismissAnimated:NO cleanup:YES];
    }
}

/**
 Initialize alert view with popup style.
 */
- (id)init
{
	self = [super init];
    if (self)
    {
        _title = nil;
        _message = nil;
        _alertViewStyle = SFAlertViewStylePopup;
    }
    return self;
}

/**
 Initialize alert view with alert view style.
 */
- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message
{
	self = [super init];
	if (self) {
		_title = title;
        _message = message;
        _alertViewStyle = SFAlertViewStyleAlertView;
	}
	return self;
}

- (void)addButtonWithTitle:(NSString *)title
                      type:(SFAlertViewButtonType)type
                   handler:(SFAlertViewHandler)handler
{
    SFAlertItem *item = [SFAlertItem new];
	item.title = title;
	item.type = type;
	item.action = handler;
	[self.items addObject:item];
}

- (void)show
{
    if (self.isVisible)
    {
        return;
    }
    
    self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
#ifdef __IPHONE_7_0
    if ([self.oldKeyWindow respondsToSelector:@selector(setTintAdjustmentMode:)]) // for iOS 7
    {
        self.oldTintAdjustmentMode = self.oldKeyWindow.tintAdjustmentMode;
        self.oldKeyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    }
#endif
    
    if (![[SFAlertView sharedQueue] containsObject:self])
    {
        [[SFAlertView sharedQueue] addObject:self];
    }
    
    if ([SFAlertView isAnimating]) {
        return; // wait for next turn
    }
    
    if ([SFAlertView currentAlertView].isVisible) {
        SFAlertView *alert = [SFAlertView currentAlertView];
        [alert dismissAnimated:YES cleanup:NO];
        return;
    }
    
    if (self.willShowHandler)
    {
        self.willShowHandler(self);
    }
    
    self.visible = YES;
    
    [SFAlertView setAnimating:YES];
    [SFAlertView setCurrentAlertView:self];
    
    // transition background
    [SFAlertView showBackground];
    
    SFAlertViewController *viewController = [[SFAlertViewController alloc]
                                             initWithNibName:nil bundle:nil];
    viewController.alertView = self;
    
    if (!self.alertWindow)
    {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelSFAlert;
        window.rootViewController = viewController;
        self.alertWindow = window;
    }
    [self.alertWindow makeKeyAndVisible];
    
    [self transitionInCompletion:^
    {
        if (self.didShowHandler)
        {
            self.didShowHandler(self);
        }
        
        [SFAlertView setAnimating:NO];
        
        NSInteger index = [[SFAlertView sharedQueue] indexOfObject:self];
        if (index < [SFAlertView sharedQueue].count - 1)
        {
            [self dismissAnimated:YES cleanup:NO]; // dismiss to show next alert view
        }
    }];
}

- (void)dismissAnimated:(BOOL)animated
{
    [self dismissAnimated:animated cleanup:YES];
}

#pragma mark - Animation Methods

- (void)transitionInCompletion:(void(^)(void))completion
{
    UIView *superview = self.superview;
    NSArray *constraints = superview.constraints;
    
    NSLayoutConstraint *verticalConstraint = nil;
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (constraint.firstAttribute == NSLayoutAttributeCenterY &&
            constraint.secondAttribute == NSLayoutAttributeCenterY)
        {
            verticalConstraint = constraint;
            break;
        }
    }
    
    if (verticalConstraint)
    {
        CGFloat height = superview.bounds.size.width;
        verticalConstraint.constant = height * 0.5 + CGRectGetHeight(self.bounds) * 0.5;
        [superview setNeedsUpdateConstraints];
        [superview layoutIfNeeded];
        
        verticalConstraint.constant = 0;
        [superview setNeedsUpdateConstraints];
        [UIView
         animateWithDuration:0.3
         delay:0.0f
         options:UIViewAnimationOptionCurveEaseOut
         animations:^
        {
            [superview layoutIfNeeded];
        }
         completion:^(BOOL finished) {
             if (completion)
             {
                 completion();
             }
         }];
    }
    else
    {
        if (completion)
        {
            completion();
        }
    }
}

- (void)transitionOutCompletion:(void(^)(void))completion
{
    UIView *superview = self.superview;
    NSArray *constraints = superview.constraints;
    
    NSLayoutConstraint *verticalConstraint = nil;
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (constraint.firstAttribute == NSLayoutAttributeCenterY &&
            constraint.secondAttribute == NSLayoutAttributeCenterY)
        {
            verticalConstraint = constraint;
            break;
        }
    }
    
    if (verticalConstraint)
    {
        CGFloat height = superview.bounds.size.width;
        verticalConstraint.constant = height * 0.5 + CGRectGetHeight(self.bounds) * 0.5;
        [superview setNeedsUpdateConstraints];
        
        [UIView
         animateWithDuration:0.3
         delay:0.0f
         options:UIViewAnimationOptionCurveEaseOut
         animations:^
         {
             [superview layoutIfNeeded];
         }
         completion:^(BOOL finished) {
             if (completion)
             {
                 completion();
             }
         }];
    }
    else
    {
        if (completion)
        {
            completion();
        }
    }
}

#pragma mark - Setup Methods

- (void)setup
{
    [self setupView];
    
    if (SFAlertViewStyleAlertView == self.alertViewStyle)
    {
        if (self.message)
        {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            
            SFAlertView *appearance = [SFAlertView appearance];
            
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.preferredMaxLayoutWidth = appearance.alertViewPreferredWidth - 40;
            label.text = self.message;
            
            [label autoSetDimension:ALDimensionWidth toSize:appearance.alertViewPreferredWidth];
            [self setupContentView:label];
        }
    }
    else if (SFAlertViewStylePopup == self.alertViewStyle)
    {
        if (self.contentView)
        {
            [self setupContentView:self.contentView];
        }
        else if (self.contentViewController)
        {
            [self setupContentView:self.contentViewController.view];
        }
    }
}

- (void)teardown
{
    [self.headerView removeFromSuperview];
    [self.separatorView removeFromSuperview];
    [self.containerView removeFromSuperview];
    self.headerView = nil;
    self.separatorView = nil;
    self.containerView = nil;
    [self.alertWindow removeFromSuperview];
    self.alertWindow = nil;
}

- (void)setupView
{
    self.backgroundColor = [UIColor whiteColor];
    
    // use autolayout
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // set minimum size with low priority constraints
    [UIView
     autoSetPriority:UILayoutPriorityDefaultLow
     forConstraints:^
    {
        [self autoSetDimensionsToSize:CGSizeMake(100, 100)];
    }];
    
    // configure content hugging and compression to fit content
    [self setContentHuggingPriority:1
                            forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:1
                            forAxis:UILayoutConstraintAxisVertical];
    
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisVertical];
    
    [self setupHeaderView];
    [self setupSeparatorView];
    [self setupContainerView];
    [self setupButtonsContainerView];
}

- (void)setupHeaderView
{
    SFAlertView *appearance = [SFAlertView appearance];
    
    self.headerView = ({
        UIView *view = [UIView new];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    
    self.closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = self.closeButtonBackgroundColor;
        [button setImage:[UIImage imageNamed:@"icon-close.png"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(dismiss)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 0;
        label.preferredMaxLayoutWidth = appearance.alertViewPreferredWidth - 40;
        label.text = self.title;
        label;
    });
    
    [self.headerView addSubview:self.closeButton];
    [self.headerView addSubview:self.titleLabel];
    
    
    
    [self.closeButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f];
    [self.closeButton autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0f];
    [self.closeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
    
    if (SFAlertViewStylePopup == self.alertViewStyle)
    {
        [self.headerView autoSetDimension:ALDimensionHeight toSize:50.0f];
        [self.closeButton autoMatchDimension:ALDimensionWidth
                                 toDimension:ALDimensionHeight
                                      ofView:self.headerView];
    }
    else
    {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.closeButton autoSetDimension:ALDimensionWidth toSize:0.0f];
        
        if (self.title)
        {
            [self.headerView autoSetDimension:ALDimensionHeight toSize:50.0f];
        }
        else
        {
            [self.headerView autoSetDimension:ALDimensionHeight toSize:0.0f];
        }
    }
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0f];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
    [self.titleLabel autoPinEdge:ALEdgeLeading
                          toEdge:ALEdgeTrailing
                          ofView:self.closeButton
                      withOffset:10.0f];
    
    [self addSubview:self.headerView];
    
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0f];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0f];
}

- (void)setupSeparatorView
{
    self.separatorView = ({
        UIView *view = [UIView new];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = self.separatorColor;
        view;
    });
    
    [self addSubview:self.separatorView];
    
    [self.separatorView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom
                             ofView:self.headerView withOffset:0.0f];
    [self.separatorView autoPinEdgeToSuperviewEdge:ALEdgeLeading
                                         withInset:0.0f];
    [self.separatorView autoPinEdgeToSuperviewEdge:ALEdgeTrailing
                                         withInset:0.0f];
    [self.separatorView autoSetDimension:ALDimensionHeight toSize:1.0f];
    
    if (SFAlertViewStyleAlertView == self.alertViewStyle)
    {
        self.separatorView.hidden = YES;
    }
}

- (void)setupContainerView
{
    self.containerView = ({
        UIView *view = [UIView new];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    
    // set minimum size with low priority constraints
    [UIView
     autoSetPriority:UILayoutPriorityDefaultLow
     forConstraints:^
    {
        [self.containerView autoSetDimensionsToSize:CGSizeMake(100.0f, 100.0f)];
    }];
    
    // configure content hugging and compression to fit content
    [self.containerView
     setContentHuggingPriority:1
     forAxis:UILayoutConstraintAxisHorizontal];
    [self.containerView
     setContentHuggingPriority:1
     forAxis:UILayoutConstraintAxisVertical];
    
    [self.containerView
     setContentCompressionResistancePriority:UILayoutPriorityRequired
     forAxis:UILayoutConstraintAxisHorizontal];
    [self.containerView
     setContentCompressionResistancePriority:UILayoutPriorityRequired
     forAxis:UILayoutConstraintAxisVertical];
    
    [self addSubview:self.containerView];
    
    [self.containerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.separatorView];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0f];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0f];
}

- (void)setupContentView:(UIView *)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:view];
    
    [view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
}

- (void)setupButtonsContainerView
{
    self.buttonsContainerView = ({
        UIView *view = [UIView new];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view;
    });
    
    self.buttons = [[NSMutableArray alloc] initWithCapacity:self.items.count];
    SFAlertView *appearance = [SFAlertView appearance];
    CGFloat buttonWidth = appearance.buttonsPreferredWidth;
    
    for (int i = 0; i < self.items.count; i++)
    {
        UIButton *button = [self buttonWithIndex:i];
        [self.buttonsContainerView addSubview:button];
        [self.buttons addObject:button];
        
        [button autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0f];
        [button autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0f];
    }
    
    if (self.buttons.count > 1)
    {
        [self.buttons autoDistributeViewsAlongAxis:ALAxisHorizontal
                                     withFixedSize:buttonWidth
                                         alignment:NSLayoutFormatAlignAllBaseline];
    }
    else
    {
        UIButton *button = [self.buttons lastObject];
        [button autoSetDimension:ALDimensionWidth toSize:buttonWidth];
        [button autoCenterInSuperview];
    }
    
    [self addSubview:self.buttonsContainerView];
    
    if (SFAlertViewStylePopup == self.alertViewStyle)
    {
        [self.buttonsContainerView autoSetDimension:ALDimensionHeight toSize:0.0f];
    }
    else
    {
        [self.buttonsContainerView autoSetDimension:ALDimensionHeight toSize:50.0f];
    }
    
    [self.buttonsContainerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom
                                    ofView:self.containerView];
    [self.buttonsContainerView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0f];
    [self.buttonsContainerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0.0f];
    [self.buttonsContainerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
}

- (UIButton *)buttonWithIndex:(NSUInteger)index
{
    SFAlertItem *item = self.items[index];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.tag = index;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (SFAlertViewButtonTypeDestructive == item.type)
    {
        [button setBackgroundColor:self.destructiveButtonColor];
    }
    else if (SFAlertViewButtonTypeCancel == item.type)
    {
        [button setBackgroundColor:self.cancelButtonColor];
    }
    else if (SFAlertViewButtonTypeDefault == item.type)
    {
        [button setBackgroundColor:self.buttonColor];
    }
    
    
    [button setTitle:item.title forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(buttonAction:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - Action Methods

- (void)buttonAction:(UIButton *)button
{
	[SFAlertView setAnimating:YES]; // set this flag to YES in order to prevent showing another alert in action block
    SFAlertItem *item = self.items[button.tag];
	if (item.action)
    {
		item.action(self);
	}
	[self dismissAnimated:YES];
}

#pragma mark - Private Dismiss Methods

- (void)dismiss
{
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated cleanup:(BOOL)cleanup
{
    BOOL isVisible = self.isVisible;
    
    if (isVisible)
    {
        if (self.willDismissHandler)
        {
            self.willDismissHandler(self);
        }
    }
    
    void (^dismissComplete)(void) = ^{
        self.visible = NO;
        
        [self teardown];
        
        [SFAlertView setCurrentAlertView:nil];
        
        SFAlertView *nextAlertView;
        NSInteger index = [[SFAlertView sharedQueue] indexOfObject:self];
        if (index != NSNotFound && index < [SFAlertView sharedQueue].count - 1)
        {
            nextAlertView = [SFAlertView sharedQueue][index + 1];
        }
        
        if (cleanup)
        {
            [[SFAlertView sharedQueue] removeObject:self];
        }
        
        [SFAlertView setAnimating:NO];
        
        if (isVisible)
        {
            if (self.didDismissHandler)
            {
                self.didDismissHandler(self);
            }
        }
        
        // check if we should show next alert
        if (!isVisible)
        {
            return;
        }
        
        if (nextAlertView)
        {
            [nextAlertView show];
        }
        else
        {
            // show last alert view
            if ([SFAlertView sharedQueue].count > 0)
            {
                SFAlertView *alert = [[SFAlertView sharedQueue] lastObject];
                [alert show];
            }
        }
    };
    
    if (animated && isVisible)
    {
        [SFAlertView setAnimating:YES];
        [self transitionOutCompletion:dismissComplete];
        
        if ([SFAlertView sharedQueue].count == 1)
        {
            [SFAlertView hideBackgroundAnimated:YES];
        }
    }
    else
    {
        dismissComplete();
        
        if ([SFAlertView sharedQueue].count == 0)
        {
            [SFAlertView hideBackgroundAnimated:YES];
        }
    }
    
    UIWindow *window = self.oldKeyWindow;
#ifdef __IPHONE_7_0
    if ([window respondsToSelector:@selector(setTintAdjustmentMode:)])
    {
        window.tintAdjustmentMode = self.oldTintAdjustmentMode;
    }
#endif
    if (!window)
    {
        window = [UIApplication sharedApplication].windows[0];
    }
    [window makeKeyWindow];
    window.hidden = NO;
}

- (void)setColor:(UIColor *)color toButtonsOfType:(SFAlertViewButtonType)type
{
    for (NSUInteger i = 0; i < self.items.count; i++)
    {
        SFAlertItem *item = self.items[i];
        if (item.type == type)
        {
            UIButton *button = self.buttons[i];
            button.backgroundColor = color;
        }
    }
}

#pragma mark - UI Appearance Methods

- (void)setCloseButtonBackgroundColor:(UIColor *)closeButtonBackgroundColor
{
    if (_closeButtonBackgroundColor == closeButtonBackgroundColor)
    {
        return;
    }
    _closeButtonBackgroundColor = closeButtonBackgroundColor;
    self.closeButton.backgroundColor = _closeButtonBackgroundColor;
}

- (void)setAlertViewPreferredWidth:(CGFloat)alertViewPreferredWidth
{
    if (_alertViewPreferredWidth == alertViewPreferredWidth)
    {
        return;
    }
    _alertViewPreferredWidth = alertViewPreferredWidth;
}

- (void)setButtonsPreferredWidth:(CGFloat)buttonsPreferredWidth
{
    if (_buttonsPreferredWidth == buttonsPreferredWidth)
    {
        return;
    }
    _buttonsPreferredWidth = buttonsPreferredWidth;
}

- (void)setCancelButtonColor:(UIColor *)cancelButtonColor
{
    if (_cancelButtonColor == cancelButtonColor)
    {
        return;
    }
    _cancelButtonColor = cancelButtonColor;
    [self setColor:_cancelButtonColor toButtonsOfType:SFAlertViewButtonTypeCancel];
    
}

- (void)setButtonColor:(UIColor *)buttonColor
{
    if (_buttonColor == buttonColor)
    {
        return;
    }
    _buttonColor = buttonColor;
    [self setColor:_buttonColor toButtonsOfType:SFAlertViewButtonTypeDefault];
}

- (void)setDestructiveButtonColor:(UIColor *)destructiveButtonColor
{
    if (_destructiveButtonColor == destructiveButtonColor)
    {
        return;
    }
    _destructiveButtonColor = destructiveButtonColor;
    [self setColor:_destructiveButtonColor toButtonsOfType:SFAlertViewButtonTypeDestructive];
}

- (void)setCloseButtonImage:(UIImage *)image
                   forState:(UIControlState)state
{
    [self.closeButton setImage:image forState:state];
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    if (_separatorColor == separatorColor)
    {
        return;
    }
    _separatorColor = separatorColor;
    self.separatorView.backgroundColor = _separatorColor;
}

@end
