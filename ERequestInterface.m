//
//  ERequestInterface.m
//  TasteBuds
//
//  Created by Jeremy Klein Sr on 4/26/14.
//  Copyright (c) 2014 Max Lemkin. All rights reserved.
//

#import "ERequestInterface.h"
#import "Singleton.h"
#import "Constants.h"

#define LOCU_SEARCH ((int) 0)
#define LOCU_DETAIL ((int) 1)
#define FOURSQUARE_SEARCH ((int) 2)
#define FOURSQUARE_MENU ((int) 3)
#define FOURSQUARE_HOURS ((int) 4)
#define FOURSQUARE_PHOTOS ((int) 5)
#define FOURSQUARE_LINK_TO_LOCU ((int) 6)




@interface ERequestInterface ()
@property (nonatomic) int provider;
@property (nonatomic) int requestType;
@property (nonatomic) BOOL internalRequest;
@property (nonatomic, strong) NSString *foursquareId;
@end

@implementation ERequestInterface
@synthesize provider;
@synthesize requestType;

- (void)requestRestaurantInfoWithId:(NSString *)foursquareId {
    NSString *path = [NSString stringWithFormat:@"venues/%@/", foursquareId];
    BZFoursquareRequest *fsRequest;
    BZFoursquare *fs = [[Singleton sharedStore] foursquare];
    fsRequest = [fs userlessRequestWithPath:path HTTPMethod:@"GET" parameters:nil delegate:self];
    [fsRequest start];
}

- (void)requestPhoto:(NSString *)foursquareId {
    NSString *path = [NSString stringWithFormat:@"venues/%@/photos/",foursquareId];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"2", @"limit", nil];
    BZFoursquareRequest *fsRequest;
    BZFoursquare *fs = [[Singleton sharedStore] foursquare];
    fsRequest = [fs userlessRequestWithPath:path HTTPMethod:@"GET" parameters:params delegate:self];
    [fsRequest start];
}

- (void)requestHoursData:(NSString *)foursquareId {
    self.provider = FOURSQUARE;
    NSString *path = [NSString stringWithFormat:@"venues/%@/hours/",foursquareId];
    BZFoursquareRequest *fsRequest;
    BZFoursquare *fs = [[Singleton sharedStore] foursquare];
    fsRequest = [fs userlessRequestWithPath:path HTTPMethod:@"GET" parameters:nil delegate:self];
    [fsRequest start];
}

- (void)requestMenuData:(NSString *)foursquareId {
    self.provider = FOURSQUARE;
    self.requestType = FOURSQUARE_MENU;
    NSString *path = [NSString stringWithFormat:@"venues/%@/menu/",foursquareId];
    BZFoursquareRequest *fsRequest;
    self.foursquareId = foursquareId;
    BZFoursquare *fs = [[Singleton sharedStore] foursquare];
    fsRequest = [fs userlessRequestWithPath:path HTTPMethod:@"GET" parameters:nil delegate:self];
    [fsRequest start];
}

- (void)requestFoursquareLinkToLocu:(NSString *)foursquareId {
    self.requestType = FOURSQUARE_LINK_TO_LOCU;
    NSString *path = [NSString stringWithFormat:@"venues/%@/links", foursquareId];
    BZFoursquareRequest *fsRequest;
    BZFoursquare *fs = [[Singleton sharedStore] foursquare];
    fsRequest = [fs userlessRequestWithPath:path HTTPMethod:@"GET" parameters:nil delegate:self];
    [fsRequest start];
}

- (void)requestLocuObjectWithFoursquareDict:(NSDictionary *)fsDict {
    self.requestType = LOCU_SEARCH;
    JKLocu *lc = [[Singleton sharedStore] locu];
    JKLocuRequest *lcRequest;
    NSString *path = @"search";
    NSString *restaurantName = [fsDict objectForKey:@"name"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            restaurantName, @"name",
                            [fsDict valueForKeyPath:@"location.address"], @"street_address",
                            [fsDict valueForKeyPath:@"location.city"], @"locality", nil];
    
    lcRequest = [lc requestWithPath:path HTTPMethod:@"GET" parameters:params delegate:self];
    [lcRequest start];
}

- (void)requestLocuMenuWithVenueID:(NSString *)venueID {
    self.requestType = LOCU_DETAIL;
    self.provider = LOCU;
    JKLocu *lc = [[Singleton sharedStore] locu];
    JKLocuRequest *lcRequest;
    NSString *path = venueID;
    lcRequest = [lc requestWithPath:path HTTPMethod:@"GET" parameters:nil delegate:self];
    [lcRequest start];
}

- (void)searchNearbyRestaurantsWithQuery:(NSString *)queryString andLocality:(NSString *)locality {
    NSString *path = @"venues/explore/";
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys: queryString, @"query", locality, @"near", nil];
    BZFoursquareRequest *fsRequest;
    BZFoursquare *fs = [[Singleton sharedStore] foursquare];
    fsRequest = [fs userlessRequestWithPath:path HTTPMethod:@"GET" parameters:params delegate:self];
    [fsRequest start];
}

- (void)searchNearbyRestaurantsWithQuery:(NSString *)queryString andLocation:(CLLocationCoordinate2D)location {
    NSString *path = @"venues/explore/";
    CLLocationCoordinate2D currentCoordinates = location;
    NSString *coordinateString = [NSString stringWithFormat:@"%f,%f", currentCoordinates.latitude, currentCoordinates.longitude];
    //hard code distance of 15 miles
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys: queryString, @"query", coordinateString, @"ll", @"24000", @"radius", @"0", @"sortByDistance", nil];
    BZFoursquareRequest *fsRequest;
    BZFoursquare *fs = [[Singleton sharedStore] foursquare];
    fsRequest = [fs userlessRequestWithPath:path HTTPMethod:@"GET" parameters:params delegate:self];
    [fsRequest start];
}

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    if (self.requestType == FOURSQUARE_MENU) {
        if ([request.response[@"menu"][@"menus"][@"count"] intValue] == 0) {
            self.internalRequest = TRUE;
            [self requestFoursquareLinkToLocu:self.foursquareId];
        } else {
            [self sendFoursquareDelegateMethodSuccess:request];
        }
    }
    
    else if (self.requestType == FOURSQUARE_LINK_TO_LOCU) {
        if (self.internalRequest) {
            BOOL foundLink = FALSE;
            for (NSDictionary *link in request.response[@"links"][@"items"]) {
                if ([link[@"provider"][@"id"]  isEqual: @"locu"]) {
                    [self requestLocuMenuWithVenueID:link[@"linkedId"]];
                    foundLink = TRUE;
                }
            }
            if (!foundLink) {
                NSError *error = [[NSError alloc] initWithDomain:@"Failed to find foursquare menu and failed to find Locu link" code:0 userInfo:nil];
                [self sendDelegateMethodError:error];
            }
        }
        /* Just a request for the locu linked id */
        else {
            [self sendFoursquareDelegateMethodSuccess:request];
        }
    }
    else {
        [self sendFoursquareDelegateMethodSuccess:request];
    }
}

- (void)jkRequestDidFinishLoading:(JKLocuRequest *)request {
    if (self.eDelegate && [self.eDelegate respondsToSelector:@selector(didFinishLoadingLocu:)]) {
        [self.eDelegate didFinishLoadingLocu:request.response];
    }
}

- (void)jkRequest:(JKLocuRequest *)request didFailWithError:(NSError *)error {
    [self sendDelegateMethodError:error];
}

- (void)sendFoursquareDelegateMethodSuccess: (BZFoursquareRequest *)request {
    if (self.eDelegate && [self.eDelegate respondsToSelector:@selector(didFinishLoadingFoursquare:)]) {
        [self.eDelegate didFinishLoadingFoursquare:request.response];
    }
}

- (void)sendDelegateMethodError: (NSError *)error {
    if (self.eDelegate && [self.eDelegate respondsToSelector:@selector(didFailWithError:)]) {
        [self.eDelegate didFailWithError:error];
    }
}

@end
