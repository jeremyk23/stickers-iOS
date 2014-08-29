//
//  FrontPageDataSource.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "FrontPageDataSource.h"
#import "CategoriesData.h"
#import "RestaurantCategoryCellData.m"
#import <Parse/Parse.h>

@implementation FrontPageDataSource

- (id)init {
    self = [super init];
    if (self) {
        self.elements = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (id)initAndConstructQuery {
    self = [self init];
    if (self) {
        [self constructQueryForFrontPageData];
    }
    return self;
}

- (void)constructQueryForFrontPageData {
    PFQuery *categoriesQuery = [PFQuery queryWithClassName:@"Category"];
    [categoriesQuery findObjectsInBackgroundWithBlock:^(NSArray *categories, NSError *error) {
        if (!error) {
            NSMutableArray *firstCellCategories = [[NSMutableArray alloc] initWithCapacity:categories.count];
            for (PFObject *category in categories) {
                CategoriesData *cData = [[CategoriesData alloc] initWithCategoryObject:category];
                [firstCellCategories addObject:cData];
            }
            NSIndexSet *frontOfArray = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, firstCellCategories.count)];
            //NSMutableArray is not thread safe so must lock it.
            NSLock *mutableArrayLock = [[NSLock alloc] init];
            [mutableArrayLock lock];
            [self.elements insertObjects:(NSArray *)firstCellCategories atIndexes:frontOfArray];
            [mutableArrayLock unlock];
        } else {
            NSLog(@"Error with categoriesQuery: %@", error);
        }
    }];
    
    PFQuery *restaurantQuery = [PFQuery queryWithClassName:@"Restaurant"];
    [restaurantQuery orderByDescending:@"createdAt"];
    restaurantQuery.limit = 10;
    [restaurantQuery whereKeyExists:@"reviews"];
    [restaurantQuery findObjectsInBackgroundWithBlock:^(NSArray *restaurants, NSError *error) {
        if (!error) {
            NSMutableArray *tempRCCDArray = [[NSMutableArray alloc] initWithCapacity:restaurants.count];
            for (PFObject *restaurant in restaurants) {
                RestaurantCategoryCellData *rData = [[RestaurantCategoryCellData alloc] initWithRestaurant:restaurant];
                [tempRCCDArray addObject:rData];
            }
            NSLock *mutableArrayLock = [[NSLock alloc] init];
            [mutableArrayLock lock];
            [self.elements addObjectsFromArray:tempRCCDArray];
            [mutableArrayLock unlock];
        }
    }];
}

@end
