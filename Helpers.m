//
//  Helpers.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/25/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "Helpers.h"
#import <Parse/Parse.h>
#import "FSBasicImage.h"

@implementation Helpers

+ (NSArray *)createPhotosArray:(PFObject *)restaurant {
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[restaurant[@"pictures"] count] + 1];
    PFFile *photoFile = restaurant[@"restaurantPhoto"];
    if (photoFile.url) {
        NSURL *mainRestaurantPhotoURL = [[NSURL alloc] initWithString:photoFile.url];
        [tempArray addObject:[[FSBasicImage alloc] initWithImageURL:mainRestaurantPhotoURL]];
    }
    for (NSString *photoURLString in restaurant[@"pictures"]) {
        if (photoURLString) {
            NSURL *photoURL = [[NSURL alloc] initWithString:photoURLString];
            if (photoURL && photoURL.scheme && photoURL.host) {
                [tempArray addObject:[[FSBasicImage alloc] initWithImageURL:photoURL]];
            }
        }
    }
    if (tempArray.count == 0) {
        [tempArray addObject:[[FSBasicImage alloc] initWithImage:[UIImage imageNamed:@"placeholder-photo.png"]]];
    }
    return (NSArray *)tempArray;
}

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage *)photo {
    UIImage *sourceImage = photo;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 0.0); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

//Use only for admin-y purposes
+ (void)printNationalPublications {
    PFQuery *blah = [PFQuery queryWithClassName:@"Publication"];
    [blah findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *bear = [[NSMutableArray alloc] initWithCapacity:objects.count];
        for (PFObject *tiger in objects) {
            NSString *locale = tiger[@"region"];
            if ([locale isEqualToString:@"National"]) {
                [bear addObject:tiger[@"name"]];
            }
        }
        NSLog(@"%@",bear);
    }];
}

//Use only for admin-y purposes
+ (void)printAllPublications {
    PFQuery *blah = [PFQuery queryWithClassName:@"Publication"];
    [blah findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *bear = [[NSMutableArray alloc] initWithCapacity:objects.count];
        for (PFObject *tiger in objects) {
            [bear addObject:tiger[@"name"]];
        }
        NSLog(@"%@",bear);
    }];
}

+ (NSSet *)nationalPublications {
    return [[NSSet alloc] initWithObjects:@"The Daily Meal", @"Thrillist", @"Eater", @"Epicurious", @"Food and Wine", @"Saveur", @"Cooking Channel TV", @"Bon app\\U00e9tit", @"OpenTable", @"Sunset", @"Opinionated About Dining", @"The New York Times", @"Fearless Critic", @"USA Today 10 Best ", @"Men's Health", @"Food Republic ", @"Via", @"SheSimmers", @"Forbes", @"USA Today ", @"The Sydney Morning Herald", @"Food Network", @"Cool Hunting", @"Behind the Food Carts", @"Feast Portland", @"Roll With Jen", @"Travel Portland", @"Delish", @"CNN", @"Urban Spoon", @"Gastronomy Blog", @"Details", @"The Guardian", @"The Globe and Mail ", @"Yahoo", @"Travel and Leisure", @"Seattle Met", @"Seattle Times", @"James Beard Foundation Awards", @"Playboy", @"GQ Magazine", @"Zagat", @"Kinfolk", @"Los Angeles Times", @"Scout Magazine", @"Munchies",nil];
}

+ (NSSet *)topPublications {
    return [[NSSet alloc] initWithObjects:@"The Oregonian", @"Portland Food And Drink", @"Food and Wine", @"Bon app\\U00e9tit", @"Wall Street Journal ", @"The New York Times", @"Fearless Critic", @"LA Weekly", @"Food Network", @"Seattle Times", @"James Beard Foundation Awards", @"GQ Magazine", @"Los Angeles Times", @"Serious Eats", @"USA Today", nil];
}


@end
