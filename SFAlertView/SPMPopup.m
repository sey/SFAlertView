//
//  SPMPopup.m
//  SPM
//
//  Created by Florian Sey on 09/01/2014.
//  Copyright (c) 2014 BGL BNP Paribas. All rights reserved.
//

#import "SPMPopup.h"

const UIWindowLevel UIWindowLevelSPMPopup = 1997.0;
const UIWindowLevel UIWindowLevelSPMPopupBackground = 1996.0;

static UIWindow *__spm_popup_background_window;

@interface SPMPopupViewController : UIViewController

@property (nonatomic, strong) SPMPopup *popup;

@end

@implementation SPMPopupViewController

- (void)loadView
{
    self.view = [UIView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add the popup to the controller view hierarchy
    [self.view addSubview:self.popup];
    
    // set constraints to center the popup horizontally and vertically
    NSLayoutConstraint *centerX = [NSLayoutConstraint
                                   constraintWithItem:self.popup
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeCenterX
                                   multiplier:1.0f
                                   constant:0.0f];
    NSLayoutConstraint *centerY = [NSLayoutConstraint
                                   constraintWithItem:self.popup
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1.0f
                                   constant:0.0f];
    [self.view addConstraints:@[ centerX, centerY ]];
}

@end

@interface SPMPopup ()

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, weak) UIWindow *oldKeyWindow;
@property (nonatomic, strong) UIWindow *alertWindow;

@property (nonatomic, assign, getter = isVisible) BOOL visible;

+ (void)showBackground;
+ (void)hideBackground;

@end

@implementation SPMPopup

+ (void)showBackground
{
    if (!__spm_popup_background_window)
    {
        __spm_popup_background_window = [[UIWindow alloc] initWithFrame:
                                         [UIScreen mainScreen].bounds];
        __spm_popup_background_window.windowLevel = UIWindowLevelSPMPopupBackground;
        __spm_popup_background_window.opaque = NO;
        __spm_popup_background_window.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        [__spm_popup_background_window makeKeyAndVisible];
        __spm_popup_background_window.alpha = 0.0f;
        [UIView
         animateWithDuration:0.3f
         animations:^
        {
            __spm_popup_background_window.alpha = 1.0f;
        }];
    }
}

+ (void)hideBackground
{
    [UIView
     animateWithDuration:0.3f
     animations:^
    {
        __spm_popup_background_window.alpha = 0.0f;
    }
     completion:^(BOOL finished)
    {
        [__spm_popup_background_window removeFromSuperview];
        __spm_popup_background_window = nil;
    }];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setupView];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}

- (void)setupView
{
    self.backgroundColor = [UIColor whiteColor];
    
    // use autolayout
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // set minimum size with low priority constraints
    NSLayoutConstraint *width = [NSLayoutConstraint
                                 constraintWithItem:self
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                 constant:100.0f];
    NSLayoutConstraint *height = [NSLayoutConstraint
                                  constraintWithItem:self
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:1.0f
                                  constant:100.0f];
    width.priority = UILayoutPriorityDefaultLow;
    height.priority = UILayoutPriorityDefaultLow;
    [self addConstraints:@[ width, height ]];
    
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
}

- (void)addContentView:(UIView *)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:view];
    [self addConstraintForView:view toView:self.containerView];
}

- (void)addConstraintForView:(UIView *)firstView toView:(UIView *)secondView
{
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:firstView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:secondView
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:10.0f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:firstView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:secondView
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:10.0f];
    NSLayoutConstraint *trailing = [NSLayoutConstraint
                                    constraintWithItem:firstView
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:secondView
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0f
                                    constant:-10.0f];
    NSLayoutConstraint *bottom = [NSLayoutConstraint
                                  constraintWithItem:firstView
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:secondView
                                  attribute:NSLayoutAttributeBottom
                                  multiplier:1.0f
                                  constant:-10.0f];
    [secondView addConstraints:@[top, bottom, leading, trailing]];
}

- (void)setupHeaderView
{
    self.headerView = ({
        UIView *view = [UIView new];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    
    self.closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor redColor];
        [button setImage:[UIImage imageNamed:@"icon-close.png"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(dismiss)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 1;
        label.text = @"PlaceholderTitle";
        label;
    });
    
    [self.headerView addSubview:self.closeButton];
    [self.headerView addSubview:self.titleLabel];
    
    {
        NSLayoutConstraint *height = [NSLayoutConstraint
                                      constraintWithItem:self.headerView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0f
                                      constant:50.0f];
        [self.headerView addConstraint:height];
    }
    
    {
        NSLayoutConstraint *top = [NSLayoutConstraint
                                   constraintWithItem:self.closeButton
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.headerView
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1.0f
                                   constant:0.0f];
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.closeButton
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self.headerView
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0f
                                       constant:0.0f];
        NSLayoutConstraint *bottom = [NSLayoutConstraint
                                      constraintWithItem:self.closeButton
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.headerView
                                      attribute:NSLayoutAttributeBottom
                                      multiplier:1.0f
                                      constant:0.0f];
        [self.headerView addConstraints:@[ top, leading, bottom ]];
        
        NSLayoutConstraint *width = [NSLayoutConstraint
                                     constraintWithItem:self.closeButton
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.headerView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:1.0f
                                     constant:0.0f];
        [self.headerView addConstraint:width];
    }
    
    {
        NSLayoutConstraint *top = [NSLayoutConstraint
                                   constraintWithItem:self.titleLabel
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.headerView
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1.0f
                                   constant:0.0f];
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.titleLabel
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self.closeButton
                                       attribute:NSLayoutAttributeTrailing
                                       multiplier:1.0f
                                       constant:10.0f];
        NSLayoutConstraint *trailing = [NSLayoutConstraint
                                        constraintWithItem:self.titleLabel
                                        attribute:NSLayoutAttributeTrailing
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.headerView
                                        attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0f
                                        constant:-10.0f];
        NSLayoutConstraint *bottom = [NSLayoutConstraint
                                      constraintWithItem:self.titleLabel
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.headerView
                                      attribute:NSLayoutAttributeBottom
                                      multiplier:1.0f
                                      constant:0.0f];
        [self.headerView addConstraints:@[ top, leading, bottom, trailing ]];
    }
    
    [self addSubview:self.headerView];
    {
        NSLayoutConstraint *top = [NSLayoutConstraint
                                   constraintWithItem:self.headerView
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1.0f
                                   constant:0.0f];
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.headerView
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0f
                                       constant:0.0f];
        NSLayoutConstraint *trailing = [NSLayoutConstraint
                                        constraintWithItem:self.headerView
                                        attribute:NSLayoutAttributeTrailing
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                        attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0f
                                        constant:0.0f];
        [self addConstraints:@[ top, leading, trailing ]];
    }
}

- (void)setupSeparatorView
{
    self.separatorView = ({
        UIView *view = [UIView new];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor grayColor];
        view;
    });
    
    [self addSubview:self.separatorView];
    
    {
        NSLayoutConstraint *top = [NSLayoutConstraint
                                   constraintWithItem:self.separatorView
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.headerView
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1.0f
                                   constant:0.0f];
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.separatorView
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0f
                                       constant:0.0f];
        NSLayoutConstraint *trailing = [NSLayoutConstraint
                                        constraintWithItem:self.separatorView
                                        attribute:NSLayoutAttributeTrailing
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                        attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0f
                                        constant:0.0f];
        NSLayoutConstraint *height = [NSLayoutConstraint
                                      constraintWithItem:self.separatorView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0
                                      constant:1.0];
        [self.separatorView addConstraint:height];
        [self addConstraints:@[ top, leading, trailing ]];
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
    NSLayoutConstraint *width = [NSLayoutConstraint
                                 constraintWithItem:self.containerView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                 constant:100.0f];
    
    NSLayoutConstraint *height = [NSLayoutConstraint
                                  constraintWithItem:self.containerView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:1.0f
                                  constant:100.0f];
    width.priority = UILayoutPriorityDefaultLow;
    height.priority = UILayoutPriorityDefaultLow;
    [self.containerView addConstraints:@[width, height]];
    
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
    {
        NSLayoutConstraint *top = [NSLayoutConstraint
                                   constraintWithItem:self.containerView
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.separatorView
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1.0f
                                   constant:0.0f];
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:self.containerView
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0f
                                       constant:0.0f];
        NSLayoutConstraint *trailing = [NSLayoutConstraint
                                        constraintWithItem:self.containerView
                                        attribute:NSLayoutAttributeTrailing
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                        attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0f
                                        constant:0.0f];
        NSLayoutConstraint *bottom = [NSLayoutConstraint
                                      constraintWithItem:self.containerView
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self
                                      attribute:NSLayoutAttributeBottom
                                      multiplier:1.0f
                                      constant:0.0f];
        [self addConstraints:@[top, leading, trailing, bottom]];
    }
}

- (void)show
{
    if (self.isVisible)
    {
        return;
    }
    
    self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    self.visible = YES;
    
    [self.class showBackground];
    
    SPMPopupViewController *controller = [SPMPopupViewController new];
    controller.popup = self;
    
    if (!self.alertWindow)
    {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelSPMPopup;
        window.rootViewController = controller;
        self.alertWindow = window;
    }

    [self.alertWindow makeKeyAndVisible];
    
    self.alpha = 0.0f;
    [UIView
     animateWithDuration:0.3
     animations:^
    {
        self.alpha = 1.0f;
    }
     completion:nil];
}

- (void)dismiss
{
    [self.class hideBackground];
    
    self.alpha = 1.0f;
    [UIView
     animateWithDuration:0.3
     animations:^
    {
         self.alpha = 0.0f;
    }
     completion:^(BOOL finished)
    {
        [self.alertWindow removeFromSuperview];
        self.alertWindow = nil;
    }];
    
    UIWindow *window = self.oldKeyWindow;
    if (!window)
    {
        window = [UIApplication sharedApplication].windows[0];
    }
    [window makeKeyAndVisible];
    window.hidden = NO;
    
    self.contentController = nil;
}

- (void)addContentViewController:(UIViewController *)viewController
{
    self.contentController = viewController;
    [self addContentView:self.contentController.view];
}

@end
