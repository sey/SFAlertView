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


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.label.text = @"kjhkhdjkfhsd jf hdsfh dhfjkhs dfkjhd jfhjdsh fjh djsfhjds hfjhds fhj djfh djsh fjhdsj fhjdshf jhf jhds fjhdsj fhdsjfh jdshfj hdjf hjdh fjhd fjh fjh djhfj dsjfh djhfj dsjfh djsfhj dshfjsd hfjhds fjhd jsfhjds fjh dsjhf jdsh fjh jfhsdjfhjsdf hjdhs fjhsd jsdh fjhsd fjhds fjh jfsdh";
}

- (IBAction)dismissAction:(id)sender
{
    [self.alertView dismissAnimated:YES];
}

@end
