//
//  AppsFlyerViewController.m
//  AppsFlyerAdobeExtension
//
//  Created by benjamin on 10/15/2018.
//  Copyright (c) 2018 benjamin. All rights reserved.
//

#import "AppsFlyerViewController.h"
#import <ACPCore/ACPCore.h>

@interface AppsFlyerViewController ()

@end

@implementation AppsFlyerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
} 

- (IBAction)trackEvt:(id)sender {
    [ACPCore trackAction:@"testAnalyticsAction" data:@{@"revenue":@"200",@"currency":@"ILS", @"freehand":@"param"}];
}


@end
