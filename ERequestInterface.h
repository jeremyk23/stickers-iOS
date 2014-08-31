//
//  ERequestInterface.h
//  TasteBuds
//
//  Created by Jeremy Klein Sr on 4/26/14.
//  Copyright (c) 2014 Max Lemkin. All rights reserved.
//

@protocol ERequestInterfaceDelegate;

// #import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BZFoursquare.h"
#import "BZFoursquareRequest.h"
#import "JKLocuRequest.h"
#import "JKLocu.h"

@interface ERequestInterface : NSObject <BZFoursquareRequestDelegate, BZFoursquareSessionDelegate, JKLocuRequestDelegate>

@property (nonatomic, weak) id<ERequestInterfaceDelegate> eDelegate;

- (void)requestRestaurantInfoWithId:(NSString *)foursquareId;
/* Locality = "city,ST" */
- (void)searchNearbyRestaurantsWithQuery:(NSString *)queryString andLocality:(NSString *)locality;
- (void)searchNearbyRestaurantsWithQuery:(NSString *)queryString andLocation:(CLLocationCoordinate2D)location;
- (void)requestPhoto:(NSString *)foursquareId;
- (void)requestHoursData:(NSString *)foursquareId;
- (void)requestMenuData:(NSString *)foursquareId;
- (void)requestFoursquareLinkToLocu:(NSString *)foursquareId;

- (void)requestLocuObjectWithFoursquareDict:(NSDictionary *)fsDict;
- (void)requestLocuMenuWithVenueID: (NSString *)venueID;

@end

@protocol ERequestInterfaceDelegate <NSObject>
@optional
- (void)didFinishLoadingFoursquare:(NSDictionary *)response;
- (void)didFinishLoadingLocu:(NSDictionary *)response;
- (void)didFailWithError:(NSError *)error;
@end
