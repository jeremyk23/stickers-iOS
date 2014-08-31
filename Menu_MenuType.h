//
//  EMenu_MenuType.h
//  Entree
//
//  Created by Jeremy Klein Sr on 7/6/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

// #import <Foundation/Foundation.h>
#import "MenuItemTableViewCell.h"

@interface Menu_MenuType : NSObject

- (NSString *)cellIdentifier;

- (UITableViewCell *)tableView:(UITableView *)tableView representationAsCellForRowAtIndexPath: (NSIndexPath *)indexPath;

@end
