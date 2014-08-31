//
//  Helpers.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/25/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

// #import <Foundation/Foundation.h>
@class PFObject;
@interface Helpers : NSObject

+ (NSArray *)createPhotosArray:(PFObject *)restaurant;
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage *)photo;
+ (NSSet *)nationalPublications;
+ (NSSet *)topPublications;

//Use only for admin-y purposes
+ (void)printNationalPublications;
+ (void)printAllPublications;

@end
