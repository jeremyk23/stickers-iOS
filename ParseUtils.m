//
//  FDParseUtils.m
//  TasteBuds
//
//  Created by Jeremy Klein Sr on 3/15/14.
//  Copyright (c) 2014 Max Lemkin. All rights reserved.
//


#import "ParseUtils.h"
#import "Singleton.h"
#import "Constants.h"
#import "Cache.h"
#import <Parse/Parse.h>

@interface ParseUtils ()
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) BOOL doesExist;
@property (nonatomic, assign) float oldRating;
@property (nonatomic, assign) float newRating;
@property (nonatomic, assign) float totalRatings;
@property (nonatomic, assign) float ratingCount;
@property (nonatomic, assign) BOOL rExists;
@end

@implementation ParseUtils
@synthesize rExists = _rExists;

- (id) init
{
    if (( self = [super init])) {
        self.rExists = NO;
    }
    return self;
}

//takes in a Dictionary with the description of the foodItem we want to submit. Also takes in a block.
- (void)submitRatingInBackground:(NSDictionary *)userSubmissionParams block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    /* Check if email is verified */
    BOOL isVerifiedEmail = [[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue];
    if (!isVerifiedEmail) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Unverified" message:@"In order to rate dishes, you'll need to verify your email. Check your inbox for a verification link." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        //        [Flurry logEvent:@"Submit_Without_EmailVerified"];
    }
    
    /* Begin submit process */
    else {
        PFObject *newFoodItem;
        BOOL dishExisted;
        //FoodItem doesn't exist, create it first
        if (userSubmissionParams[@"objectId"] == [NSNull null]) {
            dishExisted = FALSE;
            newFoodItem = [PFObject objectWithClassName:kFoodItemClassName];
            [newFoodItem setObject: [[Singleton sharedStore] currentRestaurant][@"venue"][@"id"] forKey:@"restaurantID"];
            [newFoodItem setObject:userSubmissionParams[@"name"] forKey:@"dishName"];
            
            [newFoodItem setObject:userSubmissionParams[@"rating"] forKey:@"avgRating"];
            [newFoodItem setObject:userSubmissionParams[@"rating"] forKey:@"totalRatings"];
            //first save the food item
            [newFoodItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    //then create the userSubmission.
                    [self createUserSubmissionWithParams:userSubmissionParams withFoodItem:newFoodItem andIfDishExisted:dishExisted];
                    [[Singleton sharedStore] setMostRecentPFFoodItem:newFoodItem];
                    if (completionBlock) {
                        completionBlock(succeeded,error);
                    }
                } else {
                    NSLog(@"failed to save user submission. error = %@",error);
                }
                
            }];
        }
        //FoodItem already exists, create new userSubmission
        else {
            dishExisted = TRUE;
            PFQuery *query = [PFQuery queryWithClassName:@"FoodItem"];
            [query getObjectInBackgroundWithId:userSubmissionParams[@"objectId"] block:^(PFObject *foodItem, NSError *error) {
                if (!error) {
                    [[Singleton sharedStore] setMostRecentPFFoodItem:foodItem];
                    //check if user has already rated this item
                    PFQuery *dupeUserCheck = [PFQuery queryWithClassName:kUserSubmissionClassName];
                    [dupeUserCheck whereKey:@"PFUser" equalTo:[PFUser currentUser]];
                    [dupeUserCheck whereKey:@"restaurantID" equalTo:[[Singleton sharedStore] currentRestaurant][@"venue"][@"id"]];
                    [dupeUserCheck whereKey:kUserSubmissionDishNameKey equalTo:foodItem[kFoodItemDishNameKey]];
                    [dupeUserCheck findObjectsInBackgroundWithBlock:^(NSArray *user, NSError *userCheckError) {
                        if (!userCheckError) {
                            if (user.count == 0) {
                                //user has not rated it, create new userSubmission
                                self.oldRating = 0;
                                self.newRating = [userSubmissionParams[@"rating"] floatValue];
                                //self.doesExist would go here
                                [self createUserSubmissionWithParams:userSubmissionParams withFoodItem:foodItem andIfDishExisted:dishExisted];
                                //                            [self updateAverageFromSubmitWithPFObject:foodItem];
                            }
                            //user already rated this FoodItem. Update it.
                            else {
                                self.oldRating = [[user[0] valueForKey:@"rating"] floatValue];
                                self.newRating = [userSubmissionParams[@"rating"] floatValue];
                                [user[0] setObject: userSubmissionParams[@"rating"] forKey:@"rating"];
                                
                                if (userSubmissionParams[@"comment"] != nil) {
                                    [user[0] setObject:userSubmissionParams[@"comment"] forKey:@"comment"];
                                }
                                else {
                                    [user[0] removeObjectForKey:@"comment"];
                                }
                                [user[0] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    [self updateAverageFromSubmitWithPFObject:foodItem];
                                }];
                            }
                            //user has not rated it, create new submission was executed
                            if (completionBlock) {
                                completionBlock(YES, userCheckError);
                            }
                        }
                        else {
                            NSLog(@"Error with userSubmission check: %@",userCheckError);
                            if (completionBlock) {
                                completionBlock(NO,userCheckError);
                            }
                        }
                    }]; //end of dupeUserCheck block
                } //end of FoodItem !error
                else {
                    NSLog(@"error with FoodItem retrieval: %@",error);
                    if (completionBlock) {
                        completionBlock(NO, error);
                    }
                }
            }]; //end of FoodItem background block
        }
    }
}

/*
- (void)createUserSubmissionWithParams:(NSDictionary *)userSubmissionParams withFoodItem:(PFObject *)foodItem andIfDishExisted:(BOOL)dishExisted {
    PFObject *userSubmission = [PFObject objectWithClassName:kUserSubmissionClassName];
    [userSubmission setObject:userSubmissionParams[@"rating"] forKey:@"rating"];
    [userSubmission setObject:userSubmissionParams[@"comment"] forKey:@"comment"];
    [userSubmission setObject:foodItem[kFoodItemDishNameKey] forKey:@"name"];
    [userSubmission setObject:[PFUser currentUser] forKey:@"PFUser"];
    [userSubmission setObject:userSubmissionParams[@"restaurant"] forKey:@"restaurant"];
    [userSubmission setObject: foodItem[@"restaurantID"] forKey:@"restaurantID"];
    BOOL isFacebookUser = [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
    if (isFacebookUser) {
        [self addFacebookDataToUserSubmission:userSubmission withFoodItem:foodItem andIfDishExisted:dishExisted];
    } else {
        NSString *user = [[PFUser currentUser] username];
        [userSubmission setObject:user forKey:@"user"];
        [userSubmission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                if (dishExisted) {
                    [foodItem addObject:userSubmission forKey:kFoodItemArrayKey];
                } else {
                    [foodItem setObject:[NSArray arrayWithObject:userSubmission] forKey:kFoodItemArrayKey];
                }
                //if dish existed update averages
                if (dishExisted) {
                    [foodItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self updateAverageFromSubmitWithPFObject:foodItem];
                    }];
                    //else just save it
                } else {
                    [foodItem saveInBackground];
                }
            }
        }];
    }
}



- (void)addFacebookDataToUserSubmission:(PFObject *)userSubmission withFoodItem:(PFObject *)foodItem andIfDishExisted:(BOOL)dishExisted {
    FBRequest *request = [FBRequest requestForMe];
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *facebookError) {
        if (!facebookError) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *profilePic = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            
            [userSubmission setObject:name forKey:@"user"];
            [userSubmission setObject:facebookID forKey:@"facebookID"];
            [userSubmission setObject:profilePic forKey:@"profilePic"];
            [userSubmission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    if (dishExisted) {
                        [foodItem addObject:userSubmission forKey:@"kFoodItemArrayKey"];
                    } else {
                        [foodItem setObject:[NSArray arrayWithObject:userSubmission] forKey:kFoodItemArrayKey];
                    }
                    //if dish existed update averages
                    if (dishExisted) {
                        [foodItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [self updateAverageFromSubmitWithPFObject:foodItem];
                        }];
                        //else just save it
                    } else {
                        [foodItem saveInBackground];
                    }
                    
                } else {
                    NSLog(@"failed to save user submission. error = %@",error);
                    //                    [Flurry logError:@"Failed_To_Save_User_Sub" message:@"failed to save user submission" error:error];
                }
            }];
        } else {
            NSLog(@"Error with Facebook request: %@",facebookError);
            //            [Flurry logError:@"Error_With_Facebook_Request" message:@"Error with facebook request in user submission" error:facebookError];
        }
    }];
}
*/
- (void)updateAverageFromSubmitWithPFObject:(PFObject *)foodItem {
    self.ratingCount = [[foodItem valueForKey:kFoodItemArrayKey] count];
    self.totalRatings = [[foodItem valueForKey:kFoodItemTotalRatingsKey] floatValue];
    self.totalRatings = self.totalRatings + (self.newRating - self.oldRating);
    NSString *total = [NSString stringWithFormat:@"%f", self.totalRatings];
    [foodItem setObject:total forKey:kFoodItemTotalRatingsKey];
    
    NSString *numberString = [NSString stringWithFormat:@"%f", (round(2.0f * (self.totalRatings/self.ratingCount)) / 2.0f)];
    NSString *smallerString = [numberString substringToIndex:3];
    [foodItem setObject:smallerString forKey:kFoodItemAvgRatingKey];
    [foodItem saveInBackground];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL, NSError *))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    //create a follow activity
    PFObject *followActivity = [PFObject objectWithClassName:kActivityClassName];
    [followActivity setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
    [followActivity setObject:user forKey:kActivityToUserKey];
    [followActivity setObject:kActivityTypeFollow forKey:kActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    //    [[FDCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)unfollowUserEventually:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:kActivityClassName];
    [query whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kActivityToUserKey equalTo:user];
    [query whereKey:kActivityTypeKey equalTo:kActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        //while normally there should only be one follow activity returned, we can not guarantee that.
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    //    [[FDCache sharedCache] setFollowStatus:NO user:user];
}

+ (NSArray *)getAllFoodooUsersExcludingSelf {
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
    return [query findObjects];
}

@end
