//
//  StoryTableViewCell.m
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/30/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import "StoryTableViewCell.h"

@implementation StoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onUpvote:(id)sender {
    
    self.upvoteLabel.textColor = [UIColor colorWithRed:0.203 green:0.329 blue:0.835 alpha:1];
    
    [self.delegate storyTableViewCell:self upvoteButtonDidPress:sender];

}

- (IBAction)onComment:(id)sender {
}
@end
