//
//  Helpers.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/25/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helpers : NSObject

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage *)photo;

@end
