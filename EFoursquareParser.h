//
//  EFoursquareParser.h
//  Entree
//
//  Created by Jeremy Klein Sr on 5/16/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

// #import <Foundation/Foundation.h>
@class Menu;
@interface EFoursquareParser : NSObject

- (Menu *)getFormattedEMenuObject:(NSDictionary *)response;
//returns filtered list of restaurants for populating main restaurant page
+ (NSArray *)returnRestaurantsArray:(NSDictionary *)response;

//returns the URL of the photo wider than or equal to width paramaeter, and closest to the aspect ratio of the width & height passed in.
+ (NSURL *)getPhotoClosestTo:(float)width byHeight:(float)height withResponse:(NSDictionary *)response;

+ (NSArray *)returnProfessionalTips:(NSDictionary *)response;

- (NSString *)getHoursWithTimes:(NSArray *)restaurantTimes;

@end
