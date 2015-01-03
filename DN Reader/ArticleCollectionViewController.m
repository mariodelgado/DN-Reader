//
//  ArticleCollectionViewController.m
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 1/2/15.
//  Copyright (c) 2015 Mario C. Delgado Jr. All rights reserved.
//

#import "ArticleCollectionViewController.h"
#import "StoryCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+TimeAgo.h"
#import "WebViewController.h"

@interface ArticleCollectionViewController ()

@end

@implementation ArticleCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelNormal];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationFade];
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    [super viewWillDisappear:animated];
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
    return 1;
}



- (NSString *)cellIdentifierForIndexPath: (NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        return @"storyCell";
    }
    return @"commentCell";
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.story valueForKeyPath:@"comments"] count] + 1;
}

-(CGFloat)collectionView: (UICollectionView *)collectionView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cell identifier
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    StoryCollectionViewCell *cell1 = [self.collectionView
                                      dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell1 forIndexPath:indexPath];
    CGFloat height = [cell1.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Change the cell height
    return height+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Cell identifier
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
        StoryCollectionViewCell *cell1 = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                                         
    [self configureCell:cell1 forIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell: (StoryCollectionViewCell *)cell forIndexPath: (NSIndexPath *)indexPath
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
       // NSDate *time = [self dateWithJSONString:strDate];
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
       // NSDate *time = [self dateWithJSONString:strDate];
        //      cell.timeLabel.text = [time timeAgoSimple];
        
        // Comment
        cell.descriptionLabel.text = [comment valueForKeyPath:@"body"];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
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
    }
}





#pragma mark <UICollectionViewDelegate>



@end
