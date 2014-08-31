//
//  RestaurantCategoryCellData.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "RestaurantCategoryCellData.h"
#import "Helpers.h"
#import <Parse/Parse.h>

@implementation RestaurantCategoryCellData

- (id)initWithRestaurant:(PFObject *)restaurant {
    self = [super init];
    if (self) {
        self.restaurantPictures = [Helpers createPhotosArray:restaurant];
        self.parseObjectId = restaurant.objectId;
        self.restaurantName = restaurant[@"restaurantName"];
        self.restaurantCuisine = restaurant[@"cuisine"];
        self.address = restaurant[@"address"];
        self.price = !([restaurant[@"price"] isEqual:[NSNull null]]) ? [restaurant[@"price"] intValue] : 0;
        self.reviewCount = [restaurant[@"reviews"] count];
        self.awardCount = [restaurant[@"awards"] count];
    }
    return self;
}

@end
