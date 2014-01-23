//
//  SFPopupViewController.m
//  SFAlertView
//
//  Created by Florian Sey on 23/01/2014.
//  Copyright (c) 2014 Florian Sey. All rights reserved.
//

#import "SFPopupViewController.h"
#import "SFAlertView.h"

@interface SFPopupViewController ()

@end

@implementation SFPopupViewController


- (IBAction)dismissAction:(id)sender
{
    [self.alertView dismissAnimated:YES];
}

@end
