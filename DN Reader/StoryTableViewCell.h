//
//  StoryTableViewCell.h
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/30/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoryTableViewCell;

@protocol StoryTableViewCellDelegate <NSObject>

- (void)storyTableViewCell:(StoryTableViewCell *)cell upvoteButtonDidPress:(id)sender;
- (void)storyTableViewCell:(StoryTableViewCell *)cell commentButtonDidPress:(id)sender;



@end


@interface StoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *artImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *upvoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)onUpvote:(id)sender;
- (IBAction)onComment:(id)sender;

@property (nonatomic) BOOL isUpvoted;
@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;


@property (weak, nonatomic) id  delegate;

@end
