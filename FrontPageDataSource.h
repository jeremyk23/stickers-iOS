//
//  FrontPageDataSource.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "FrontPageCategoryData.h"

@protocol FrontPageDataSourceDelegate;

static NSString *CategoryCollectionViewCellIdentifier = @"CategoryCollectionViewCellIdentifier";
static NSString *CategoryWithRestaurantCollectionCellIdentifier = @"CategoryWithRestaurantCollectionCellIdentifier";
static NSString *RestaurantCollectionViewCellIdentifier = @"RestaurantCollectionViewCellIdentifier";

@interface FrontPageDataSource : NSObject


@property (weak) id <FrontPageDataSourceDelegate> fpDatasourceDelegate;
@property (nonatomic, strong) NSMutableArray *elements;


- (UITableViewCell *)tableView:(UITableView *)tableView configureCellForIndexPath:(NSIndexPath *)indexPath;


- (NSInteger)collectionView:(UICollectionView *)collectionView configureNumberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView configureItemAtIndexPath:(NSIndexPath *)indexPath;

- (id)initAndConstructQuery;

@end

@protocol FrontPageDataSourceDelegate <NSObject>

- (void)shouldReloadTable;

@end
