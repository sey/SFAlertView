//
//  SFViewController.m
//  SFAlertView
//
//  Created by Florian Sey on 18/01/2014.
//  Copyright (c) 2014 Florian Sey. All rights reserved.
//

#import "SFViewController.h"
#import "SFAlertView.h"

@interface SFViewController ()

@end

@implementation SFViewController

- (IBAction)showAlertViewAction:(id)sender
{
    [[SFAlertView appearance] setButtonsPreferredWidth:150];
    {
        SFAlertView *alertView = [[SFAlertView alloc] initWithTitle:@"Ullamcorper Dapibus Nibh"
                                                         andMessage:@"Sit Dolor Bibendum Venenatis"];
        
        [alertView addButtonWithTitle:@"Cancel" type:SFAlertViewButtonTypeCancel handler:^(SFAlertView *alertView) {
            
        }];
        [alertView addButtonWithTitle:@"Ok" type:SFAlertViewButtonTypeDefault handler:nil];
        [alertView show];
    }
    
    {
        SFAlertView *alertView = [[SFAlertView alloc] initWithTitle:@"Vehicula Amet Elit"
                                                         andMessage:@"Vestibulum id ligula porta felis euismod semper. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Maecenas faucibus mollis interdum."];
        
        [alertView addButtonWithTitle:@"Ok" type:SFAlertViewButtonTypeDefault handler:nil];
        [alertView show];
    }
    
    {
        SFAlertView *alertView = [[SFAlertView alloc] initWithTitle:nil
                                                         andMessage:@"Vestibulum id ligula porta felis euismod semper. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Maecenas faucibus mollis interdum."];
        
        [alertView addButtonWithTitle:@"Ok" type:SFAlertViewButtonTypeDefault handler:nil];
        [alertView show];
    }
}

- (IBAction)showPopupViewAction:(id)sender
{
    SFAlertView *appearance = [SFAlertView appearance];
    [appearance setCloseButtonImage:[UIImage imageNamed:@"icon-close.png"]
                           forState:UIControlStateNormal];
    {
        UINib *nib = [UINib nibWithNibName:@"SFPopupContentView" bundle:nil];
        NSArray *views = [nib instantiateWithOwner:nil options:nil];
        UIView *view = [views lastObject];
        
        SFAlertView *alertView = [SFAlertView new];
        alertView.title = @"Ipsum Lorem Dolor";
        [alertView setContentView:view];
        [alertView show];
    }
    
    {
        UINib *nib = [UINib nibWithNibName:@"SFPopupContentView" bundle:nil];
        NSArray *views = [nib instantiateWithOwner:nil options:nil];
        UIView *view = [views lastObject];
        
        SFAlertView *alertView = [SFAlertView new];
        [alertView setContentView:view];
        [alertView show];
    }
}

@end
