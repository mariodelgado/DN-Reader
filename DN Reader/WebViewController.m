//
//  WebViewController.m
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/31/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load web page
//    NSString *fullURL = @"http://designcode.io";
    
    
    NSURL *url = [NSURL URLWithString:self.fullURL];
    NSURLRequest *requestObject = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObject];

}



@end
