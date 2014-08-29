//
//  RestaurantCategoryCellData.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrontPageCategoryData.h"

@interface RestaurantCategoryCellData : FrontPageCategoryData

@property (nonatomic, strong) PFFile *restaurantPicture;
@property (nonatomic, strong) NSString *parseObjectId;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSString *restaurantCuisine;
@property  int price;
@property  NSUInteger reviewCount;
@property  NSUInteger awardCount;

- (id)initWithRestaurant:(PFObject *)restaurant;

@end
