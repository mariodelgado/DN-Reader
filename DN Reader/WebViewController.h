//
//  WebViewController.h
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/31/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) NSString *fullURL;


@end
