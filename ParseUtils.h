//
//  FDParseUtils.h
//  TasteBuds
//
//  Created by Jeremy Klein Sr on 3/15/14.
//  Copyright (c) 2014 Max Lemkin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFObject;
@class PFUser;
@interface ParseUtils : NSObject

- (void)submitRatingInBackground:(NSDictionary *)userSubmissionParams block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
- (void)createUserSubmissionWithParams:(NSDictionary *)userSubmissionParams withFoodItem:(PFObject *)foodItem andIfDishExisted:(BOOL)dishExisted;
- (void)addFacebookDataToUserSubmission:(PFObject *)userSubmission withFoodItem:(PFObject *)foodItem andIfDishExisted:(BOOL)dishExisted;

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;

+ (NSArray *)getAllFoodooUsersExcludingSelf;

@end
