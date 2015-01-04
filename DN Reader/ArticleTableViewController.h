//
//  ArticleTableViewController.h
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/31/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleTableViewController : UITableViewController

@property (nonatomic,strong) NSDictionary *story;
- (IBAction)onUpvote:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;

@end
