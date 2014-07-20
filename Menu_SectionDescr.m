//
//  EMenu_SectionTitleWithDescr.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "Menu_SectionDescr.h"

NSString static *sectionDescrCell = @"sectionDescrCell";

@implementation Menu_SectionDescr

- (id)initWithSectionDescription:(NSString *)description {
    self = [super init];
    if (self) {
        self.sectionDescription = description;
    }
    return self;
}

- (UITableViewCell *)tableView: (UITableView *)tableView representationAsCellForRowAtIndexPath: (NSIndexPath *)indexPath {
    
    
    MenuItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sectionDescrCell];
    if (!cell) {
        cell = [[MenuItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sectionDescrCell];
    }
//    [cell updateFonts];
    cell.bodyLabel.font = [UIFont fontWithName:@"GillSans-LightItalic" size:16.0];
    cell.bodyLabel.textAlignment = NSTextAlignmentCenter;
    cell.bodyLabel.textColor = [UIColor blackColor];
    cell.bodyLabel.text = self.sectionDescription;
//    cell.bodyLabel.font = [UIFont fontWithName:@"GillSans-Light" size:14.0f];
    
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (NSString *)cellIdentifier {
    return sectionDescrCell;
}

@end
