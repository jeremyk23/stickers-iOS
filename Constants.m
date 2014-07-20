//
//  Constants.m
//  Best Bites
//
//  Created by Jeremy Klein Sr on 5/16/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark Foursquare Constants
int const FOURSQUARE = 1000;
NSString * const kFSClientId = @"3PYJRD3QMAJL3KG4A1WLG0Q0J1UN25D1GSOEGGIYXCRBMO0Y";
NSString * const kFSClientSecret = @"AH3C4KCXGPMMPYBWWX1M13KOGXMK34KW13UTLF2BR2X1NYHD";

#pragma mark Locu Constants
int const LOCU = 1001;
NSString * const kLocuApiKey = @"4441dc638e16a38e943e9dcba4bee672abf3584d";

//Menu Constants
NSString * const kMenu_menuName = @"menuName";
NSString * const kMenu_sectionArray = @"sectionArray";
NSString * const kMenu_menuArray = @"menuArray";

#pragma mark Parse Classes
//Activity Constants
NSString * const kActivityClassName = @"Activity";
NSString * const kActivityToUserKey = @"toUser";
NSString * const kActivityFromUserKey = @"fromUser";
NSString * const kActivityTypeKey = @"type";

NSString * const kActivityTypeFollow = @"follow";

//UserSubmission Constants
NSString * const kUserSubmissionClassName = @"UserSubmission";
NSString * const kUserSubmissionUserNameKey = @"user";
NSString * const kUserSubmissionDishNameKey = @"userSubDishName";
NSString * const kUserSubmissionRestaurantNameKey = @"restaurant";

//User Constants
NSString * const kUserClassName = @"User";
NSString * const kUserObjectIdKey = @"objectId";
NSString * const kUserDisplayNameKey = @"displayName";
NSString * const kUserProfilePicKey = @"profilePic";

//FoodItem Constants
NSString * const kFoodItemClassName = @"FoodItem";
NSString * const kFoodItemRestaurantIdKey = @"restaurantId";
NSString * const kFoodItemDishNameKey = @"dishName";
NSString * const kFoodItemAvgRatingKey = @"avgRating";
NSString * const kFoodItemRestaurantNameKey = @"restaurantName";
NSString * const kFoodItemArrayKey = @"foodItemsArray";
NSString * const kFoodItemTotalRatingsKey = @"totalRatings";

//FeaturedDishes Constants
NSString * const kFeaturedDishesClassName = @"FeaturedDishes";
NSString * const kFeaturedDishesCityKey = @"city";
NSString * const kFeaturedDishesStateKey = @"state";
NSString * const kFeaturedDishes_featuredDishes = @"featuredDishes";

@end

