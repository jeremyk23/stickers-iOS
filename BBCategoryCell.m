//
//  BBCategoryCell.m
//  Best Bites
//
//  Created by Jeremy Klein Sr on 8/22/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "BBCategoryCell.h"

@implementation BBCategoryCell

- (void)awakeFromNib {
    
}

- (void)layoutSubviews {
    [self bringSubviewToFront:self.restaurantNameLabel];
}
@end
