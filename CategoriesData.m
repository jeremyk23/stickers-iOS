//
//  CategoriesData.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "CategoriesData.h"
#import <Parse/Parse.h>

@implementation CategoriesData

- (id)initWithCategoryObject:(PFObject *)category {
    self = [super init];
    if (self) {
        self.categoryPicture = category[@"categoryPicture"];
        self.categoryTitle = category[@"categoryName"];
        self.parseCategoryObjectId = category.objectId;
    }
    return self;
}

@end
