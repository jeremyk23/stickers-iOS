//
//  FrontPageDataSource.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "FrontPageDataSource.h"
#import "CategoriesData.h"
#import "RestaurantCategory.h"
#import "FPCategoryGroup.h"
#import "RestaurantCategoryCellData.h"
#import "AFTableViewCell.h"
#import "SingleRestaurantTableViewCell.h"
#import "Constants.h"
#import <Parse/Parse.h>

# define NUMBER_OF_ASYNC_CALLS 1

@interface FrontPageDataSource ()
@property int numberOfAsyncCallsFinished;
@end

@implementation FrontPageDataSource

- (id)init {
    self = [super init];
    if (self) {
        self.elements = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (id)initAndConstructQuery {
    self = [self init];
    if (self) {
        [self constructQueryForFrontPageData];
    }
    return self;
}

- (void)constructQueryForFrontPageData {
    PFQuery *categoriesQuery = [PFQuery queryWithClassName:@"Category"];
    [categoriesQuery findObjectsInBackgroundWithBlock:^(NSArray *categories, NSError *error) {
        if (!error) {
            NSMutableArray *firstCellCategories = [[NSMutableArray alloc] initWithCapacity:categories.count];
            for (PFObject *category in categories) {
                CategoriesData *cData = [[CategoriesData alloc] initWithCategoryObject:category];
                [firstCellCategories addObject:cData];
            }
            //NSMutableArray is not thread safe so must lock it.
            NSLock *mutableArrayLock = [[NSLock alloc] init];
            [mutableArrayLock lock];
            FPCategoryGroup *categoryGroup = [[FPCategoryGroup alloc] initWithItems:(NSArray *)firstCellCategories andGroupType:kCategoriesOnlyGroup];
            [self.elements insertObject:categoryGroup atIndex:0];
            [mutableArrayLock unlock];
            self.numberOfAsyncCallsFinished += 1;
            [self checkForUpdate];
        } else {
            NSLog(@"Error with categoriesQuery: %@", error);
        }
    }];
    /*
    PFQuery *restaurantQuery = [PFQuery queryWithClassName:@"Restaurant"];
    [restaurantQuery orderByDescending:@"createdAt"];
    restaurantQuery.limit = 10;
    [restaurantQuery whereKeyExists:@"reviews"];
    [restaurantQuery findObjectsInBackgroundWithBlock:^(NSArray *restaurants, NSError *error) {
        if (!error) {
            NSMutableArray *tempRCCDArray = [[NSMutableArray alloc] initWithCapacity:restaurants.count];
            for (PFObject *restaurant in restaurants) {
                RestaurantCategoryCellData *rData = [[RestaurantCategoryCellData alloc] initWithRestaurant:restaurant];
                FPCategoryGroup *categoryGroup = [[FPCategoryGroup alloc] initWithItems:rData.restaurantPictures andGroupType:kSingleRestaurantGroup];
                categoryGroup.cellData = rData;
                [tempRCCDArray addObject:categoryGroup];
            }
            NSLock *mutableArrayLock = [[NSLock alloc] init];
            [mutableArrayLock lock];
            [self.elements addObjectsFromArray:tempRCCDArray];
            [mutableArrayLock unlock];
            self.numberOfAsyncCallsFinished += 1;
            [self checkForUpdate];
        }
    }];
     */
}

- (void)checkForUpdate {
    if (self.numberOfAsyncCallsFinished == NUMBER_OF_ASYNC_CALLS) {
        if (self.fpDatasourceDelegate && [self.fpDatasourceDelegate respondsToSelector:@selector(shouldReloadTable)]) {
            [self.fpDatasourceDelegate shouldReloadTable];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView configureCellForIndexPath:(NSIndexPath *)indexPath {
    NSLock *mutableArrayLock = [[NSLock alloc] init];
    [mutableArrayLock lock];
    FPCategoryGroup *categoryGroup = self.elements[indexPath.row];
    [mutableArrayLock unlock];
    if (categoryGroup.groupType == kSingleRestaurantGroup) {
        static NSString *RestaurantCellIdentifier = @"RestaurantCellIdentifier";
        SingleRestaurantTableViewCell *cell = (SingleRestaurantTableViewCell *)[tableView dequeueReusableCellWithIdentifier:RestaurantCellIdentifier];
        if (!cell) {
            cell = [[SingleRestaurantTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RestaurantCellIdentifier];
        }
        [cell.collectionView registerNib:[UINib nibWithNibName:@"RestaurantCategoryCollectionViewCell" bundle:[NSBundle mainBundle]]
              forCellWithReuseIdentifier:RestaurantCollectionViewCellIdentifier];
        RestaurantCategoryCellData *rcData = (RestaurantCategoryCellData *)categoryGroup.cellData;
        cell.categoryLabel.text = rcData.address;
        cell.restaurantNameLabel.text = rcData.restaurantName;
        return cell;
    }
    
    static NSString *CellIdentifier = @"CellIdentifier";
    AFTableViewCell *cell = (AFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if (categoryGroup.groupType == kCategoriesOnlyGroup) {
        [cell.collectionView registerNib:[UINib nibWithNibName:@"CategoryCollectionViewCell" bundle:[NSBundle mainBundle]]
              forCellWithReuseIdentifier:CategoryCollectionViewCellIdentifier];
    } else if (categoryGroup.groupType == kCategoryWithRestaurantGroup) {
        [cell.collectionView registerNib:[UINib nibWithNibName:@"RestaurantCategoryCollectionViewCell" bundle:[NSBundle mainBundle]]
              forCellWithReuseIdentifier:RestaurantCollectionViewCellIdentifier];
        CategoriesData *cData = (CategoriesData *)categoryGroup.cellData;
        cell.categoryLabel.text = cData.categoryTitle;
        [cell displayCategoryLabel];
    }
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView configureItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLock *mutableArrayLock = [[NSLock alloc] init];
    [mutableArrayLock lock];
    FPCategoryGroup *fpCategoryGroup = self.elements[collectionView.tag];
    [mutableArrayLock unlock];
    CategoryGroupType groupType = fpCategoryGroup.groupType;
    UICollectionViewCell *cell;
    if (groupType == kCategoriesOnlyGroup) {
        cell = [fpCategoryGroup.items[indexPath.row] collectionView:collectionView representationAsCellForItemAtIndexPath:indexPath];
    }
    return cell;
}

//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    
//    
//}


@end
