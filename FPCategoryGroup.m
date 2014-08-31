//
//  FPCategoryGroups.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/29/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "FPCategoryGroup.h"

@implementation FPCategoryGroup

- (id)initWithItems:(NSArray *)items andGroupType:(CategoryGroupType)groupType {
    self = [super init];
    if (self) {
        self.items = items;
        self.groupType = groupType;
    }
    return self;
}

@end
