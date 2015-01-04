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
#import "ACSimpleKeychain.h"
#import "ArticleTableViewController.h"

@interface HomeTableViewController ()
@property (nonatomic, strong) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (weak, nonatomic) id  delegate;


@end

@implementation HomeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // See if user has token
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials = [keychain credentialsForUsername:@"token" service:@"DN"];
    NSString *token = [credentials valueForKey:ACKeychainIdentifier];
    if(!token) {
        // If has no token, show Login
        [self performSegueWithIdentifier:@"homeToLoginScene" sender:self];
    }
    
    
    // Pull to refresh in viewDidLoad
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self getData];
    
   }



- (void)refresh
{
    // Get data
    [self getData];
}

- (void)getData{
    
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
                                                
                                                // End refresh
                                                [self.refreshControl endRefreshing];
                                                
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
    
    [self configureCell:cell forIndexPath:indexPath];

    

    cell.delegate = self;

    return cell;
}

-(void)configureCell: (StoryTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
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
    
    
    // Reset when cells are re-rendered
    // Change button image
    //  cell.upvoteImageView.image = [UIImage imageNamed:@"icon-upvote"];
    // Change text color
    cell.upvoteLabel.textColor = [UIColor colorWithRed:0.627 green:0.69 blue:0.745 alpha:1];
    // Toggle
    cell.isUpvoted = NO;
    
    
    [DNUser isUpvotedWithStory:story completion:^(BOOL succeed, NSError *error) {
        // Change button image
        //   cell.upvoteImageView.image = [UIImage imageNamed:@"icon-upvote-active"];
        // Change text color
        cell.upvoteLabel.textColor = [UIColor colorWithRed:0.203 green:0.329 blue:0.835 alpha:1];
        // Toggle
        cell.isUpvoted = YES;
    }];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Change the cell height
    return 88;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *story = [self.data valueForKey:@"stories"][indexPath.row];
    [self performSegueWithIdentifier:@"homeToArticleScene" sender:story];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

//send data

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"homeToArticleScene"]){
        ArticleTableViewController *controller = segue.destinationViewController;
        controller.story = sender;
        
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


#pragma mark StoryTableViewCellDelegate
- (void)storyTableViewCell:(StoryTableViewCell *)cell upvoteButtonDidPress:(id)sender
{
    // Get indexPath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    // Get data from the array at position of the row
    NSDictionary *story = [self.data valueForKey:@"stories"][indexPath.row];
    
    // Only do API upvote if story hasn't been upvoted
    if(!cell.isUpvoted) {
        // Change button image
      //  cell.upvoteImageView.image = [UIImage imageNamed:@"icon-upvote-active"];
        // Change text color
        cell.upvoteLabel.textColor = [UIColor colorWithRed:0.203 green:0.329 blue:0.835 alpha:1];
        // Toggle
        cell.isUpvoted = YES;
        // Pop animation
       // UIImageView *view = cell.upvoteImageView;
//        NSTimeInterval duration = 0.5;
//        NSTimeInterval delay = 0;
//        [UIView animateKeyframesWithDuration:duration/3 delay:delay options:0 animations:^{
//            // End
//            view.transform = CGAffineTransformMakeScale(1.5, 1.5);
//        } completion:^(BOOL finished) {
//            [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
//                // End
//                view.transform = CGAffineTransformMakeScale(0.7, 0.7);
//            } completion:^(BOOL finished) {
//                [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
//                    // End
//                    view.transform = CGAffineTransformMakeScale(1, 1);
//                } completion:nil];
//            }];
//        }];
        // Increment number
        int upvoteInt = [[story valueForKey:@"vote_count"] intValue] +1;
        cell.upvoteLabel.text = [NSString stringWithFormat:@"%d", upvoteInt];
        // Do API Post
        [DNAPI upvoteWithStory:story];
        // Save to Keychain
        [DNUser saveUpvoteWithStory:story];
    }
}


@end
