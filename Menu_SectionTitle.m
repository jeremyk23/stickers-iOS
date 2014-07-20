//
//  EMenu_SectionTitle.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "Menu_SectionTitle.h"

@implementation Menu_SectionTitle

- (id)initWithSectionTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.sectionTitle = title;
    }
    return self;
}

@end
