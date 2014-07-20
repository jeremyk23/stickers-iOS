//
//  EMenu_Dish.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "Menu_Dish.h"

NSString static *dishCell = @"dishCell";

@implementation Menu_Dish

- (id)initWithDishName:(NSString *)name {
    self = [super init];
    if (self) {
        self.dishName = name;
    }
    return self;
}

- (UITableViewCell *)tableView: (UITableView *)tableView representationAsCellForRowAtIndexPath: (NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dishCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dishCell];
    }
    cell.textLabel.text = self.dishName;
    cell.textLabel.font = [UIFont fontWithName:@"GillSans-Light" size:14.0f];
    return cell;
}

- (NSString *)cellIdentifier {
    return dishCell;
}

@end
