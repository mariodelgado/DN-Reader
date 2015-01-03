//
//  ArticleCollectionViewController.h
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 1/2/15.
//  Copyright (c) 2015 Mario C. Delgado Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+TimeAgo.h"
#import "WebViewController.h"

@interface ArticleCollectionViewController : UICollectionViewController

@property (nonatomic,strong) NSDictionary *story;


@end
