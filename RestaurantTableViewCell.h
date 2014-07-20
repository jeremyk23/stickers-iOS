//
//  RestaurantTableViewCell.h
//  Entree
//
//  Created by Jeremy Klein Sr on 7/3/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import <Parse/Parse.h>
#import "BBLabel.h"

@interface RestaurantTableViewCell : PFTableViewCell

@property (nonatomic, strong)  BBLabel *restaurantNameLabel;
@property (nonatomic, strong)  BBLabel *restaurantCuisine;
@property (nonatomic, strong)  BBLabel *avgScoreLabel;
@property (nonatomic, strong)  BBLabel *numberOfReviews;
@property (nonatomic, strong)  BBLabel *priceLabel;
@property (nonatomic, strong)  BBLabel *addressLabel;

+ (CGFloat)rowHeight;

- (void)setDollarSign:(NSNumber *)priceTier;

@end
