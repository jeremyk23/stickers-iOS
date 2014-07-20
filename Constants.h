//
//  Constants.h
//  Best Bites
//
//  Created by Jeremy Klein Sr on 5/16/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

//Locu Constants
extern int const LOCU;
extern NSString * const kLocuApiKey;

//Foursquare Constants
extern int const FOURSQUARE;
extern NSString * const kFSClientId;
extern NSString * const kFSClientSecret;

//Menu Constants
extern NSString * const kMenu_menuName;
extern NSString * const kMenu_sectionArray;
extern NSString * const kMenu_menuArray;


#pragma mark Parse Classes
//Activity Constants
extern NSString * const kActivityClassName;
extern NSString * const kActivityToUserKey;
extern NSString * const kActivityFromUserKey;
extern NSString * const kActivityTypeKey;

extern NSString * const kActivityTypeFollow;

//UserSubmission Constants
extern NSString * const kUserSubmissionClassName;
extern NSString * const kUserSubmissionUserNameKey;
extern NSString * const kUserSubmissionDishNameKey;
extern NSString * const kUserSubmissionRestaurantNameKey;

//User Constants
extern NSString * const kUserClassName;
extern NSString * const kUserObjectIdKey;
extern NSString * const kUserDisplayNameKey;
extern NSString * const kUserProfilePicKey;

//FoodItem Constants
extern NSString * const kFoodItemClassName;
extern NSString * const kFoodItemRestaurantIdKey;
extern NSString * const kFoodItemDishNameKey;
extern NSString * const kFoodItemRestaurantNameKey;
extern NSString * const kFoodItemAvgRatingKey;
extern NSString * const kFoodItemArrayKey;
extern NSString * const kFoodItemTotalRatingsKey;

//FeaturedDishes Constants
extern NSString * const kFeaturedDishesClassName;
extern NSString * const kFeaturedDishesCityKey;
extern NSString * const kFeaturedDishesStateKey;
extern NSString * const kFeaturedDishes_featuredDishes;

@end
