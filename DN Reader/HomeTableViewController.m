//
//  HomeTableViewController.m
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/30/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import "HomeTableViewController.h"
#import "DNAPI.h"
#import "StoryTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+TimeAgo.h"

@interface HomeTableViewController ()
@property (nonatomic, strong) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation HomeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get data
    NSURLRequest *request = [NSURLRequest requestWithPattern:DNAPIStories object:nil];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            NSError *serializeError;
                                            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializeError];
                                            double delayInSeconds = 1.0f;   // Just for debug
                                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                
                                                // Get response
                                                self.data = json;
                                                NSLog(@"%@", self.data);
                                                
                                                // Reload data after Get
                                                [self.tableView reloadData];
                                                
                                                // Hide loading
                                                self.loadingIndicator.hidden = YES;
                                                
                                            });
                                        }];
    [task resume];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.data valueForKey:@"stories"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storyCell" forIndexPath:indexPath];
    
    // Get data from the array at position of the row
    NSDictionary *story = [self.data valueForKey:@"stories"][indexPath.row];
    // Apply the data to each row
    cell.titleLabel.text = [story valueForKey:@"title"];
    cell.authorLabel.text = [NSString stringWithFormat:@"%@, %@", [story valueForKey:@"user_display_name"], [story valueForKey:@"user_job"]];
    cell.commentLabel.text = [NSString stringWithFormat:@"%@", [story valueForKey:@"comment_count"]];
    cell.upvoteLabel.text = [NSString stringWithFormat:@"%@", [story valueForKey:@"vote_count"]];
    
    // Image from Web
    [cell.avatarImageView sd_setImageWithURL:[story valueForKeyPath:@"user_portrait_url"]];
    
    // Simple date
  //  NSString* strDate = [story objectForKey:@"created_at"];
  //  NSDate *time = [self dateWithJSONString:strDate];
  //  cell.timeLabel.text = [time timeAgoSimple];
  //  NSLog(@"%@", [time timeAgoSimple]);
    
    // Badges
    cell.artImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"badge-%@", [story valueForKeyPath:@"badge"]]];
    
    // Remove Accessory
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Change the cell height
    return 88;
}

- (NSDate*)dateWithJSONString:(NSString*)dateStr
{
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    // This is for check the output
    // Convert date object to desired output format
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"]; // Here you can change your require output date format EX. @"EEE, MMM d YYYY"
    dateStr = [dateFormat stringFromDate:date];
    
    return date;
}

@end
