//
//  CategoriesData.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

//// #import <Foundation/Foundation.h>
#import "FrontPageCategoryData.h"

@interface CategoriesData : FrontPageCategoryData

- (id)initWithCategoryObject:(PFObject *)category;

@property (nonatomic, strong) PFFile *categoryPicture;
@property (nonatomic, strong) NSString *categoryTitle;
@property (nonatomic, strong) NSString *parseCategoryObjectId;
@property (nonatomic, strong) NSArray *restaurants;
// optional. May be used for when category isn't an array of restaurants on the category object
@property (nonatomic, strong) PFQuery *categoryQuery;

@end
