//
//  HomeCollectionViewController.m
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 1/1/15.
//  Copyright (c) 2015 Mario C. Delgado Jr. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "DNAPI.h"
#import "StoryCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+TimeAgo.h"
#import "ACSimpleKeychain.h"
#import "ArticleTableViewController.h"

@interface HomeCollectionViewController ()
@property (nonatomic, strong) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;


@end

@implementation HomeCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Pull to refresh in viewDidLoad
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
//    self.refreshControl = refreshControl;
    [self getData];
    
    
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // See if user has token
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials = [keychain credentialsForUsername:@"token" service:@"DN"];
    NSString *token = [credentials valueForKey:ACKeychainIdentifier];
    if(!token) {
        // If has no token, show Login
        [self performSegueWithIdentifier:@"homeToLoginScene" sender:self];
    }

    [self getData];


}

-(void)getData {
    
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
                                                [self.collectionView reloadData];
                                                
                                                // Hide loading
                                                self.loadingIndicator.hidden = YES;
                                                
                                                //end refresh
                                           //     [self.refreshControl endRefreshing];
                                                
                                                
                                            });
                                        }];
    [task resume];
    
}


- (void)refresh
{
    // Get data
    [self getData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete method implementation -- Return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete method implementation -- Return the number of items in the section
    return [[self.data valueForKey:@"stories"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    StoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"storyCell" forIndexPath:indexPath];
    
    
    // Get data from the array at position of the row
    NSDictionary *story = [self.data valueForKey:@"stories"][indexPath.row];
    // Apply the data to each row
    
    cell.titleLabel.text = [story valueForKey:@"title"];
    cell.authorLabel.text = [NSString stringWithFormat:@"%@, %@", [story valueForKey:@"user_display_name"], [story valueForKey:@"user_job"]];
    cell.commentLabel.text = [NSString stringWithFormat:@"%@", [story valueForKey:@"comment_count"]];
    
    cell.upvoteLabel.text = [NSString stringWithFormat:@"%@", [story valueForKey:@"vote_count"]];

    [cell.avatarImageView sd_setImageWithURL:[story valueForKeyPath:@"user_portrait_url"]];
    cell.artImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"badge-%@", [story valueForKeyPath:@"badge"]]];
    
    
    
    
    
    // Simple date
    //  NSString* strDate = [story objectForKey:@"created_at"];
    //  NSDate *time = [self dateWithJSONString:strDate];
    //  cell.timeLabel.text = [time timeAgoSimple];
    //  NSLog(@"%@", [time timeAgoSimple]);

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Change the cell height
    return 88;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *story = [self.data valueForKey:@"stories"][indexPath.row];
    [self performSegueWithIdentifier:@"homeToArticleScene" sender:story];
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
@end