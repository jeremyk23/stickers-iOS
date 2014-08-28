//
//  MosaicData.m
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/17/13.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import "MosaicData.h"
#import <Parse/Parse.h>
@implementation MosaicData
@synthesize title;

-(id)initWithPFFile:(PFFile *)file publicationName:(NSString *)publicationName andDatePublished:(NSDate *)date {
    self = [super init];
    if (self) {
        self.parseFile = file;
        self.title = publicationName;
        if (date) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
            self.yearPublished = [NSString stringWithFormat:@"%ld", (long)[components year]];
        } else {
            self.yearPublished = @"";
        }
        
        self.isTopPublication = FALSE;
        self.firstTimeShown = YES;
    }
    return self;
}

-(NSString *)description{
    NSString *retVal = [NSString stringWithFormat:@"%@ %@", [super description], self.title];
    return retVal;
}

@end
