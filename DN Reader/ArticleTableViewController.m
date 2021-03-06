//
//  ArticleTableViewController.m
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/31/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import "ArticleTableViewController.h"
#import "StoryTableViewCell.h"
#import "WebViewController.h"
#import "UIImageView+WebCache.h"
#import "NSDate+TimeAgo.h"
#import "DNAPI.h"


@interface ArticleTableViewController () <StoryTableViewCellDelegate>
@end

@implementation ArticleTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    // is upvoted?
    [DNUser isUpvotedWithStory:self.story completion:^(BOOL succeed, NSError *error) {
        [self.upvoteButton setTitle:@"Upvoted!" forState:UIControlStateSelected];
        self.upvoteButton.enabled = NO;
    }];
    
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    

    [self.tableView reloadData];
    
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
    
    // Set delegate
    
    return cell;
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
        [cell.descriptionLabel sizeToFit];
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
        [cell.descriptionLabel sizeToFit];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // When user selects a row
    NSString *fullURL = [self.story valueForKey:@"url"];
    if(indexPath.row == 0) {
        // Perform segue if first row
        [self performSegueWithIdentifier:@"articleToWebScene" sender:fullURL];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"articleToWebScene"]) {
        WebViewController *controller = segue.destinationViewController;
        controller.fullURL = sender;
        controller.story = self.story;
    }
//    if([segue.identifier isEqualToString:@"articleToCommentScene"]) {
//        UINavigationController *navController = segue.destinationViewController;
//        CommentViewController *controller = [navController viewControllers][0];
//        controller.story = self.story;
//    }
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

- (IBAction)onUpvote:(id)sender {
    
    // indexPath at 0 is the Story cell
    StoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"storyCell" forIndexPath:0];
    // If story hasn't been upvoted, upvote and change the button title

    if(!cell.isUpvoted) {
        [self upvoteStory:cell];
        [self.upvoteButton setTitle:@"Upvoted!" forState:UIControlStateSelected];
        self.upvoteButton.enabled = NO;
    }
}

- (void)upvoteStory: (StoryTableViewCell *)cell
    {
        // Get indexPath
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        // Get data from the array at position of the row
        NSDictionary *story = self.story;
        
        // Only do API upvote if story hasn't been upvoted
        if(!cell.isUpvoted) {
            NSLog(@"upvoted yo");
            // Change button image
          //  cell.upvoteImageView.image = [UIImage imageNamed:@"icon-upvote-active"];
            // Change text color
            cell.upvoteLabel.textColor = [UIColor colorWithRed:0.203 green:0.329 blue:0.835 alpha:1];
            // Toggle
            cell.isUpvoted = YES;

            
            // Story only
            if(indexPath.row == 0) {
                // Increment number
                int upvoteInt = [[story valueForKey:@"vote_count"] intValue] +1;
                cell.upvoteLabel.text = [NSString stringWithFormat:@"%d", upvoteInt];
                // Do API Post
                [DNAPI upvoteWithStory:story];
                // Save to Keychain
                [DNUser saveUpvoteWithStory:story];
            }
        }
    }
    
- (void)storyTableViewCell:(StoryTableViewCell *)cell commentButtonDidPress:(id)sender
    {
        
    }



    
@end

