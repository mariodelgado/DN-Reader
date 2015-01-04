//
//  WebViewController.m
//  DNApp
//
//  Created by Mario C. Delgado Jr. on 5/20/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import "WebViewController.h"
#import "ArticleTableViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Load web page
//    NSString *fullURL = @"http://designcode.io";
    NSURL *url = [NSURL URLWithString:self.fullURL];
    NSURLRequest *requestObject = [NSURLRequest requestWithURL:url];
    [self.viewWeb loadRequest:requestObject];
    
    // Update Comments button
    NSString *buttonTitle = [NSString stringWithFormat:@"%@ Comments", [self.story valueForKey:@"comment_count"]];
    [self.commentsButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"webToArticleScene"]) {
        ArticleTableViewController *controller = segue.destinationViewController;
        controller.story = sender;
    }
}

- (IBAction)commentsButtonDidPress:(id)sender
{
    [self performSegueWithIdentifier:@"webToArticleScene" sender:self.story];
}
- (IBAction)actionButtonDidPress:(id)sender
{
    // Set up title and link
    NSString *string = [NSString stringWithFormat:@"%@: ", [self.story valueForKey:@"title"]];
    NSURL *URL = [NSURL URLWithString:self.fullURL];
    
    // Show Share view
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                      applicationActivities:nil];
    [self presentViewController:activityViewController
                                       animated:YES
                                     completion:nil];
}
@end
