//
//  SPMPopup.h
//  SPM
//
//  Created by Florian Sey on 09/01/2014.
//  Copyright (c) 2014 BGL BNP Paribas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPMPopup : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIViewController *contentController;

- (void)addContentView:(UIView *)view;
- (void)addContentViewController:(UIViewController *)viewController;
- (void)show;
- (void)dismiss;

@end
