//
//  ViewController.m
//  AAMFeedbackViewController
//
//  Created by 深津 貴之 on 11/11/30.
//  Copyright (c) 2011年 Art & Mobile. All rights reserved.
//

#import "ViewController.h"
#import "AAMFeedbackViewController.h"

@implementation ViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"Send Feedback" forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.center = CGPointMake(160, 240);
    [btn addTarget:self action:@selector(btnDidPress:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn];
}

- (void)btnDidPress:(id)sender
{
    AAMFeedbackViewController *vc = [[[AAMFeedbackViewController alloc]init]autorelease];
    vc.toRecipients = [NSArray arrayWithObject:@"YOUR_CONTACT@email.com"];
    vc.ccRecipients = nil;
    vc.bccRecipients = nil;
    UINavigationController *nvc = [[[UINavigationController alloc]initWithRootViewController:vc]autorelease];
    [self presentModalViewController:nvc animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
