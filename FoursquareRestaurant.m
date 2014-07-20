//
//  FoursquareRestaurant.m
//  Entree
//
//  Created by Jeremy Klein Sr on 6/30/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "FoursquareRestaurant.h"

@implementation FoursquareRestaurant

- (UITableViewCell *)tableView: (UITableView *)tableView representationAsCellForRowAtIndexPath: (NSIndexPath *)indexPath {
    static NSString *FoursquareCellIdentifier = @"FoursquareCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:FoursquareCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:FoursquareCellIdentifier];
    }
    cell.textLabel.text = self.restaurantName;
    cell.detailTextLabel.text = self.restaurantCuisine;
    return cell;
}

@end
