//
//  FoursquareRestaurant.h
//  Entree
//
//  Created by Jeremy Klein Sr on 6/30/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "RestaurantModel.h"

@interface FoursquareRestaurant : RestaurantModel



- (UITableViewCell *)tableView: (UITableView *)tableView representationAsCellForRowAtIndexPath: (NSIndexPath *)indexPath;

@end
