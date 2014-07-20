//
//  FoursquareRestaurantViewController.h
//  Best Bites
//
//  Created by Jeremy Klein Sr on 7/19/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "RestaurantViewController.h"

@interface FoursquareRestaurantViewController : RestaurantViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFsID:(NSString *)foursquareId;

@end
