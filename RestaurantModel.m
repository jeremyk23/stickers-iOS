//
//  RestaurantModel.m
//  Entree
//
//  Created by Jeremy Klein Sr on 6/28/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "RestaurantModel.h"

@implementation RestaurantModel

- (id)initWith:(NSString *)restaraurantName
    andCuisine:(NSString *)cusine
    andAddress:(NSString *)address {
    self = [super init];
    if (self) {
        self.restaurantName = restaraurantName;
        self.restaurantCuisine = cusine;
        self.address = address;
    }
    return self;
}

+ (int)providerIsParse { return 1; }
+ (int)providerIsFoursquare { return 0; }

@end
