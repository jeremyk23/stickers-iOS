//
//  Singleton.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/16/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "Singleton.h"
#import "Constants.h"
#import "BZFoursquare.h"
#import "JKLocu.h"

@interface Singleton()
@property (nonatomic) int refreshCheckDistance;
@property (nonatomic) BOOL restaurantsNeedRefresh;
@end

@implementation Singleton

NSString *const _NOTIFICATION_LOCATION_UPDATE = @"ELocationUpdate";

NSString * const FILTER_LESS_THAN_1 = @"1610";
NSString * const FILTER_LESS_THAN_5 = @"8000";
NSString * const FILTER_LESS_THAN_10 = @"16000";
NSString * const FILTER_LESS_THAN_15 = @"24000";
NSString * const FILTER_LESS_THAN_20 = @"32000";

+(Singleton *)sharedStore {
    static Singleton *sharedStore = nil;
    if(!sharedStore) {
        sharedStore = [[super allocWithZone:nil]init];
    }
    return sharedStore;
}
//makes sure allocWithZone doesn't create a new instance of PortfoliosStore
+(id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

-(id)init {
    self = [super init];
    if (self) {
        [self initializeLocationManager];
        [self initializeFoursquareObject];
        [self initializeLocuObject];
        
        self.restaurantsNeedRefresh = true;
        //set default refresh check
        self.refreshCheckDistance = [FILTER_LESS_THAN_5 intValue] / 2;
    }
    return self;
}

- (void)requestWhenInUseAuthorization {
    NSLog(@"ran this");
}

- (void)initializeLocationManager {
    //set properties of our CLLocationManager. Set accuracy to nearest ten meters, when to update, etc.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 60.0f; //update every 200 ft.
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)initializeFoursquareObject {
    self.foursquare = [[BZFoursquare alloc] initWithClientID:kFSClientId callbackURL:@"entreefoods.com"];
    self.foursquare.clientSecret = kFSClientSecret;
    self.foursquare.version = @"20140226";
    self.foursquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
}

- (void)initializeLocuObject {
    self.locu = [[JKLocu alloc] initWithApiKey:kLocuApiKey];
}

#pragma mark CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = locations.lastObject;
    NSLog(@"self.currentLocation %@", self.currentLocation);
    
    //set current city and state for featured dishes
    if (!self.currentCity) {
        [self reverseLookupCity];
    }
    
    if (!self.lastRestaurantRefreshLoc) {
        self.lastRestaurantRefreshLoc = locations.lastObject;
    } else {
        CLLocationDistance distance = [self.currentLocation distanceFromLocation:self.lastRestaurantRefreshLoc];
        if (distance >= self.refreshCheckDistance) {
            self.restaurantsNeedRefresh = TRUE;
        }
    }
    if (self.restaurantsNeedRefresh) {
        //make sure we are still in the same city. After update, refresh data tables.
        [self reverseLookupCity];
        self.restaurantsNeedRefresh = FALSE;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"ERROR: %@", error);
}

- (void)reverseLookupCity {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            NSLog(@"Running geocoder");
            [[NSNotificationCenter defaultCenter] postNotificationName:_NOTIFICATION_LOCATION_UPDATE object:self];
            CLPlacemark *address = placemarks[0];
            self.currentCity = address.locality;
            self.currentState = address.administrativeArea;
        } else {
            NSLog(@"error with reverse geocode %@", error);
        }
    }];
}
/*---- FILTER METHODS ----*/
- (NSString *)filterLessThan1 {
    self.refreshCheckDistance = [FILTER_LESS_THAN_1 intValue] / 2;
    return FILTER_LESS_THAN_1;
}

- (NSString *)filterLessThan5 {
    self.refreshCheckDistance = [FILTER_LESS_THAN_5 intValue] / 2;
    return FILTER_LESS_THAN_5;
}

- (NSString *)filterLessThan10 {
    self.refreshCheckDistance = [FILTER_LESS_THAN_10 intValue] / 2;
    return FILTER_LESS_THAN_10;
}

- (NSString *)filterLessThan15 {
    self.refreshCheckDistance = [FILTER_LESS_THAN_15 intValue] / 2;
    return FILTER_LESS_THAN_15;
}

- (NSString *)filterLessThan20 {
    self.refreshCheckDistance = [FILTER_LESS_THAN_20 intValue] / 2;
    return FILTER_LESS_THAN_20;
}


@end
