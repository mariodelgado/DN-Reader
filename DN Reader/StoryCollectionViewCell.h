//
//  StoryCollectionViewCell.h
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 1/1/15.
//  Copyright (c) 2015 Mario C. Delgado Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *artImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *upvoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
