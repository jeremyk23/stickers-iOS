//
//  SingleRestaurantTableViewCell.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/29/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "SingleRestaurantTableViewCell.h"

@implementation SingleRestaurantTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.restaurantNameLabel = [[BBLabel alloc] init];
    self.restaurantNameLabel.frame = CGRectMake(0.0f, CGRectGetMinY(self.categoryLabel.frame) - 30.0f, 320.0f, 30.0f);
    self.restaurantNameLabel.textColor = [UIColor whiteColor];
    self.restaurantNameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.restaurantNameLabel];
    return self;
}

@end
