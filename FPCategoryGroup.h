//
//  FPCategoryGroups.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/29/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

//// #import <Foundation/Foundation.h>
#import "FrontPageCategoryData.h"


typedef enum {
    kCategoriesOnlyGroup,
    kCategoryWithRestaurantGroup,
    kSingleRestaurantGroup
} CategoryGroupType;

@interface FPCategoryGroup : NSObject

// optional. Stores data that remains on the cell while user swipes through collection
@property (nonatomic, strong) FrontPageCategoryData *cellData;
@property (nonatomic, strong) NSArray *items;
@property CategoryGroupType groupType;

- (id)initWithItems:(NSArray *)items andGroupType:(CategoryGroupType)groupType;

@end
