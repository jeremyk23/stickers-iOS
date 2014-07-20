//
//  EMenu.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "Menu.h"
#import "EFoursquareParser.h"

@implementation Menu

- (id)init {
    self = [super init];
    if (self) {
        self.arrayOfMenus = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
