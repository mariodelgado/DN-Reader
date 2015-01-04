//
//  WebViewController.h
//  DNApp
//
//  Created by Mario C. Delgado Jr. on 5/20/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *viewWeb;
@property (weak, nonatomic) NSString *fullURL;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
- (IBAction)commentsButtonDidPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
- (IBAction)actionButtonDidPress:(id)sender;
@property (weak, nonatomic) NSDictionary *story;

@end
