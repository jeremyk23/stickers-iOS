//
//  BBLabel.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/28/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "BBLabel.h"

@implementation BBLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont fontWithName:@"GillSans" size:18.0f];
        self.textColor = [UIColor colorWithRed:253.0f/255.0f green:254.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }
    return self;
}

@end
