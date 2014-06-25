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
#import "NIAttributedLabel.h"
#import "UIView+AutoLayout.h"

@interface SFViewController ()
<UITableViewDataSource, UITableViewDelegate, NIAttributedLabelDelegate>

@property (nonatomic, strong) SFAlertView *currentAlertView;
@property (nonatomic, strong) NSArray *alertViewSelectors;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation SFViewController

- (NSArray *)alertViewSelectors
{
    if (!_alertViewSelectors)
    {
        _alertViewSelectors = @[ NSStringFromSelector(@selector(testAlertViewWithNoTitleNoMessage)),
                                 NSStringFromSelector(@selector(testAlertViewWithTitleNoMessage)),
                                 NSStringFromSelector(@selector(testWithCustomLabelPopup)) ];
    }
    return _alertViewSelectors;
}

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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [SFAlertView class];
    [[SFAlertView appearance] setAlertViewPreferredWidth:400];
    [[SFAlertView appearance] setButtonsPreferredWidth:180];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.alertViewSelectors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectorString = self.alertViewSelectors[indexPath.row];
    
    static NSString *Cell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    
    cell.textLabel.text = selectorString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectorString = self.alertViewSelectors[indexPath.row];
    SEL selector = NSSelectorFromString(selectorString);
    
    ((void (*)(id, SEL))[self methodForSelector:selector])(self, selector);
}

- (void)logout
{
    [SFAlertView cleanPopup];
}

- (IBAction)showAlertViewAction:(id)sender
{
    [self testAlertViewWithTitleNoMessage];
}

- (IBAction)showPopupViewAction:(id)sender
{
    [self testWithCustomLabelPopup];
    return;
    
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

- (void)testWithCustomLabelPopup
{
    NSString *message = @"For more information, call (+352) 42 42 – 7000 between 8 am and 6 pm, Monday to Friday." @"For more information, call (+352) 42 42 – 7000 between 8 am and 6 pm, Monday to Friday." @"For more information, call (+352) 42 42 – 7000 between 8 am and 6 pm, Monday to Friday.";
    
    NIAttributedLabel *label = [NIAttributedLabel new];
    label.numberOfLines = 0;
    label.dataDetectorTypes = NSTextCheckingTypePhoneNumber;
    label.autoDetectLinks = YES;
    label.delegate = self;
    label.linkColor = [UIColor redColor];
    label.text = message;
    [label autoSetDimension:ALDimensionWidth toSize:280];
    SFAlertView *alertView = [[SFAlertView alloc] init];
    alertView.hideCloseButton = YES;
    [alertView setContentView:label];
    
    [alertView
     addButtonWithTitle:NSLocalizedString(@"OK", nil)
     type:SFAlertViewButtonTypeDefault
     handler:nil];
    [alertView show];
}

- (void)testAlertViewWithNoTitleNoMessage
{
    SFAlertView *alertView = [self alertViewWithTitle:nil andMessage:nil];
    [alertView show];
}

- (void)testAlertViewWithTitleNoMessage
{
    SFAlertView *alertView = [self alertViewWithTitle:@"Test title" andMessage:nil];
    [alertView show];
}



- (SFAlertView *)alertViewWithTitle:(NSString *)title andMessage:(NSString *)message
{
    SFAlertView *alertView = [[SFAlertView alloc] initWithTitle:title
                                                     andMessage:message];
    self.currentAlertView = alertView;
    return alertView;
}

- (void)dismissCurrentAlertView
{
    [self.currentAlertView dismissAnimated:YES];
}

- (NSString *)cleanPhoneNumber:(NSString *)input
{
    NSString *output = @"";
    for (int i=0; i<[input length]; i++) {
        if (isdigit([input characterAtIndex:i])) {
            output=   [output  stringByAppendingFormat:@"%c",[input characterAtIndex:i]];
        }
    }
    
    return  output;
}

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    if (NSTextCheckingTypePhoneNumber == result.resultType)
    {
        NSLog(@"phone number: %@", result.phoneNumber);
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [self cleanPhoneNumber:result.phoneNumber]]];
        NSLog(@"phone number url: %@", url);
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (BOOL)attributedLabel:(NIAttributedLabel *)attributedLabel shouldPresentActionSheet:(UIActionSheet *)actionSheet withTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    return NO;
}

@end
