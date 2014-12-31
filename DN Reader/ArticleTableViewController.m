//
//  ArticleTableViewController.m
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/31/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import "ArticleTableViewController.h"
#import "StoryTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+TimeAgo.h"


@interface ArticleTableViewController ()

@end

@implementation ArticleTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Testing data
    NSLog(@"Test story%@", self.story);
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
    return [[self.story valueForKeyPath:@"comments"] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cell identifier
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    StoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cell identifier
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    StoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell forIndexPath:indexPath];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Change the cell height
    return height+1;
}

#pragma mark - Private methods

- (NSString *)cellIdentifierForIndexPath: (NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        return @"storyCell";
    }
    return @"commentCell";
}

- (void)configureCell: (StoryTableViewCell *)cell forIndexPath: (NSIndexPath *)indexPath
{
    // If first row
    if(indexPath.row == 0) {
        
        // Values
        NSDictionary *story = self.story;
        
        cell.titleLabel.text = [story valueForKeyPath:@"title"];
        cell.authorLabel.text = [NSString stringWithFormat:@"%@, %@", [story valueForKey:@"user_display_name"], [story valueForKey:@"user_job"]];
        cell.commentLabel.text = [NSString stringWithFormat:@"%@", [story valueForKey:@"comment_count"]];
        cell.upvoteLabel.text = [NSString stringWithFormat:@"%@", [story valueForKey:@"vote_count"]];
        
        // Image from Web
        [cell.avatarImageView setImageWithURL:[story valueForKeyPath:@"user_portrait_url"]];
        
        // Simple date
        NSString* strDate = [story objectForKey:@"created_at"];
        NSDate *time = [self dateWithJSONString:strDate];
    //    cell.timeLabel.text = [time timeAgoSimple];
        
        // Comment
        cell.descriptionLabel.text = [story valueForKeyPath:@"comment"];
    }
    else {
        // Values
    
        NSDictionary *comment = self.story[@"comments"][indexPath.row-1];
        
        cell.authorLabel.text = [NSString stringWithFormat:@"%@, %@", [comment valueForKey:@"user_display_name"], [comment valueForKey:@"user_job"]];
        cell.commentLabel.text = @"Reply";
        cell.upvoteLabel.text = [NSString stringWithFormat:@"%@", [comment valueForKey:@"vote_count"]];
        
        // Image from Web
        [cell.avatarImageView setImageWithURL:[comment valueForKeyPath:@"user_portrait_url"]];
        
        // Simple date
        NSString* strDate = [comment objectForKey:@"created_at"];
        NSDate *time = [self dateWithJSONString:strDate];
  //      cell.timeLabel.text = [time timeAgoSimple];
        
        // Comment
        cell.descriptionLabel.text = [comment valueForKeyPath:@"body"];
    }
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
