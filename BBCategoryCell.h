//
//  BBCategoryCell.h
//  Best Bites
//
//  Created by Jeremy Klein Sr on 8/22/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBLabel.h"
#import <Parse/Parse.h>

@interface BBCategoryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet BBLabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *restaurantPhoto;


@end
