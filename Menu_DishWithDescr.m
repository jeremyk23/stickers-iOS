//
//  EMenu_DishWithDescr.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "Menu_DishWithDescr.h"

NSString static *dishWithDescrCell = @"dishWithDescrCell";

@implementation Menu_DishWithDescr

- (UITableViewCell *)tableView: (UITableView *)tableView representationAsCellForRowAtIndexPath: (NSIndexPath *)indexPath {
    
    MenuItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dishWithDescrCell];
    if (!cell) {
        cell = [[MenuItemTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:dishWithDescrCell];
    }
    [cell updateFonts];
    cell.titleLabel.text = self.dishName;
//    cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:14.0f];
    
    cell.bodyLabel.text = self.dishDescription;
//    cell.detailTextLabel.font = [UIFont fontWithName:@"GillSans-Light" size:14.0f];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (NSString *)cellIdentifier {
    return dishWithDescrCell;
}

@end
