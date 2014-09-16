//
//  RestaurantListViewControllerTableViewController.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/30/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFViewController.h"
#import "FSPhotoGalleryCollectionView.h"
@class CategoriesData;

@interface RestaurantListViewController : UITableViewController <FSPhotoGalleryCollectionViewDelegate>

- (id)initWithCategoryData:(CategoriesData *)categoryData;

@end
