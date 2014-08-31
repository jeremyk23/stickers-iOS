//
//  Singleton.h
//  Entree
//
//  Created by Jeremy Klein Sr on 5/16/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

// #import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "BZFoursquareRequest.h"
#import "JKLocu.h"

@class BZFoursquare;
@class BZFoursquareRequest;
@class PFObject;

@interface Singleton : NSObject <CLLocationManagerDelegate, BZFoursquareRequestDelegate, JKLocuRequestDelegate>

extern NSString *const _NOTIFICATION_LOCATION_UPDATE;

extern NSString * const FILTER_LESS_THAN_1;
extern NSString * const FILTER_LESS_THAN_5;
extern NSString * const FILTER_LESS_THAN_10;
extern NSString * const FILTER_LESS_THAN_15;
extern NSString * const FILTER_LESS_THAN_20;

@property (nonatomic, strong) JKLocu *locu;
@property (nonatomic, strong) BZFoursquare *foursquare;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastRestaurantRefreshLoc;

/*access these throughout the app for currently selected restaurant properties*/
@property (nonatomic, strong) NSString *currentCity;
@property (nonatomic, strong) NSString *currentState;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, strong) NSDictionary *currentRestaurant;
@property (nonatomic, strong) PFObject *mostRecentPFFoodItem;


+ (Singleton *)sharedStore;
/*initialized at startup when Singletion is first initialized*/
- (void)initializeLocationManager;
- (void)initializeFoursquareObject;
- (void)initializeLocuObject;

@end
