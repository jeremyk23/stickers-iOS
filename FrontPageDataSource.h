//
//  FrontPageDataSource.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrontPageCategoryData.h"

@interface FrontPageDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *elements;

- (id)initAndConstructQuery;

@end
