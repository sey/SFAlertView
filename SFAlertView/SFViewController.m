//
//  SFViewController.m
//  SFAlertView
//
//  Created by Florian Sey on 18/01/2014.
//  Copyright (c) 2014 Florian Sey. All rights reserved.
//

#import "SFViewController.h"
#import "SFPopupViewController.h"

#import "SFAlertView.h"

@interface SFViewController ()

@end

@implementation SFViewController

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)logout
{
    [SFAlertView cleanPopup];
}

- (IBAction)showAlertViewAction:(id)sender
{
    [[SFAlertView appearance] setButtonsPreferredWidth:180];
    {
        SFAlertView *alertView = [[SFAlertView alloc] initWithTitle:@"Ullamcorper Dapibus Nibh"
                                                         andMessage:@"Sit Dolor Bibendum Venenatis"];
        
        [alertView addButtonWithTitle:@"Cancel" type:SFAlertViewButtonTypeCancel handler:^(SFAlertView *alertView) {
            
        }];
        [alertView addButtonWithTitle:@"DECONNEXION" image:[UIImage imageNamed:@"on-off.png"] type:SFAlertViewButtonTypeDefault handler:nil];
        [alertView show];
    }
}

- (IBAction)showPopupViewAction:(id)sender
{
    SFAlertView *appearance = [SFAlertView appearance];
    [appearance setCloseButtonImage:[UIImage imageNamed:@"icon-close.png"]
                           forState:UIControlStateNormal];
    {
        SFPopupViewController *controller = [SFPopupViewController new];
        SFAlertView *alertView = [SFAlertView new];
        //alertView.title = @"Ipsum Lorem Dolor";
        alertView.hideCloseButton = YES;
        [alertView setContentViewController:controller];
        [alertView show];
    }
    /*
    {
        UINib *nib = [UINib nibWithNibName:@"SFPopupContentView" bundle:nil];
        NSArray *views = [nib instantiateWithOwner:nil options:nil];
        UIView *view = [views lastObject];
        
        SFAlertView *alertView = [SFAlertView new];
        alertView.title = @"Ipsum Lorem Dolor";
        [alertView setContentView:view];
        [alertView show];
    }
    */
    
}

@end
