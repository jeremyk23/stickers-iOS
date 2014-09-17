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
#import "RestaurantListViewController.h"
#import "RestaurantViewController.h"
#import "AFTableViewCell.h"
#import "SingleRestaurantTableViewCell.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "FSPhotoGalleryCollectionView.h"

# define NUMBER_OF_ASYNC_CALLS 2

@interface FrontPageDataSource ()
@property int numberOfAsyncCallsFinished;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation FrontPageDataSource

- (id)init {
    self = [super init];
    if (self) {
        self.elements = [[NSMutableArray alloc] initWithCapacity:10];
        self.contentOffsetDictionary = [NSMutableDictionary dictionary];
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
}

- (void)checkForUpdate {
    if (self.numberOfAsyncCallsFinished == NUMBER_OF_ASYNC_CALLS) {
        if (self.fpDatasourceDelegate && [self.fpDatasourceDelegate respondsToSelector:@selector(shouldReloadTable)]) {
            [self.fpDatasourceDelegate shouldReloadTable];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.elements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLock *mutableArrayLock = [[NSLock alloc] init];
    [mutableArrayLock lock];
    FPCategoryGroup *categoryGroup = self.elements[indexPath.row];
    [mutableArrayLock unlock];
    if (categoryGroup.groupType == kSingleRestaurantGroup) {
        SingleRestaurantTableViewCell *cell = (SingleRestaurantTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSingleRestaurantTVCellIdentifier];
        RestaurantCategoryCellData *restaurantData = (RestaurantCategoryCellData *)categoryGroup.cellData;
        FSPhotoGalleryCollectionView *fsCollectionView;
        if (!cell) {
            cell = [[SingleRestaurantTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSingleRestaurantTVCellIdentifier];
            fsCollectionView = (FSPhotoGalleryCollectionView *)cell.collectionView;
            fsCollectionView.photoGalleryDelegate = self;
        } else {
            fsCollectionView = (FSPhotoGalleryCollectionView *)cell.collectionView;
        }
        
        [fsCollectionView setPicturesWithArray:restaurantData.restaurantPictures andObjectId:restaurantData.parseObjectId];
        cell.restaurantNameLabel.text = restaurantData.restaurantName;
        cell.categoryLabel.text = restaurantData.address;
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
////    NSLock *mutableArrayLock = [[NSLock alloc] init];
////    [mutableArrayLock lock];
////    FPCategoryGroup *fpCategoryGroup = self.elements[collectionView.tag];
////    [mutableArrayLock unlock];
////    CategoryGroupType groupType = fpCategoryGroup.groupType;
////    if (groupType == kCategoriesOnlyGroup) {
////        if (self.fpDatasourceDelegate && [self.fpDatasourceDelegate respondsToSelector:@selector(didSelectItemAndShouldPushViewController:)]) {
////            CategoriesData *cData = (CategoriesData *)fpCategoryGroup.items[indexPath.row];
////            RestaurantListViewController *restaurantLVC = [[RestaurantListViewController alloc] initWithCategoryData:cData];
////            [self.fpDatasourceDelegate didSelectItemAndShouldPushViewController:restaurantLVC];
////        }
////    } else if (groupType == kSingleRestaurantGroup) {
////        if (self.fpDatasourceDelegate && [self.fpDatasourceDelegate respondsToSelector:@selector(didSelectItemAndShouldPushViewController:)]) {
////            RestaurantCategoryCellData *rData = (RestaurantCategoryCellData *)fpCategoryGroup.items[indexPath.row];
////            RestaurantViewController *restaurantVC = [[RestaurantViewController alloc] initWithNibName:@"RestaurantViewController" bundle:nil andParseObjectId:rData.parseObjectId];
////            [self.fpDatasourceDelegate didSelectItemAndShouldPushViewController:restaurantVC];
////        }
////    }
//
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(AFTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLock *mutableArrayLock = [[NSLock alloc] init];
    [mutableArrayLock lock];
    FPCategoryGroup *categoryGroup = self.elements[indexPath.row];
    [mutableArrayLock unlock];
    if (categoryGroup.groupType == kSingleRestaurantGroup) {
        cell.collectionView.tag = indexPath.row;
    } else {
        [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    }
    
    NSInteger index = cell.collectionView.tag;
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 245.0f;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView configureCellForIndexPath:(NSIndexPath *)indexPath {
//    NSLock *mutableArrayLock = [[NSLock alloc] init];
//    [mutableArrayLock lock];
//    FPCategoryGroup *categoryGroup = self.elements[indexPath.row];
//    [mutableArrayLock unlock];
//    if (categoryGroup.groupType == kSingleRestaurantGroup) {
//        SingleRestaurantTableViewCell *cell = (SingleRestaurantTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSingleRestaurantTVCellIdentifier];
//        RestaurantCategoryCellData *restaurantData = (RestaurantCategoryCellData *)categoryGroup.cellData;
//        FSPhotoGalleryCollectionView *fsCollectionView;
//        if (!cell) {
//            cell = [[SingleRestaurantTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSingleRestaurantTVCellIdentifier];
//            fsCollectionView = (FSPhotoGalleryCollectionView *)cell.collectionView;
//            fsCollectionView.photoGalleryDelegate = self;
//        } else {
//            fsCollectionView = (FSPhotoGalleryCollectionView *)cell.collectionView;
//        }
//        
//        [fsCollectionView setPicturesWithArray:restaurantData.restaurantPictures];
//        cell.restaurantNameLabel.text = restaurantData.restaurantName;
//        cell.categoryLabel.text = restaurantData.address;
//        return cell;
//    }
//    
//    static NSString *CellIdentifier = @"CellIdentifier";
//    AFTableViewCell *cell = (AFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    
//    if (categoryGroup.groupType == kCategoriesOnlyGroup) {
//        [cell.collectionView registerNib:[UINib nibWithNibName:@"CategoryCollectionViewCell" bundle:[NSBundle mainBundle]]
//              forCellWithReuseIdentifier:CategoryCollectionViewCellIdentifier];
//    } else if (categoryGroup.groupType == kCategoryWithRestaurantGroup) {
//        [cell.collectionView registerNib:[UINib nibWithNibName:@"RestaurantCategoryCollectionViewCell" bundle:[NSBundle mainBundle]]
//              forCellWithReuseIdentifier:RestaurantCollectionViewCellIdentifier];
//        CategoriesData *cData = (CategoriesData *)categoryGroup.cellData;
//        cell.categoryLabel.text = cData.categoryTitle;
//        [cell displayCategoryLabel];
//    }
//    return cell;
//}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLock *mutableArrayLock = [[NSLock alloc] init];
    [mutableArrayLock lock];
    FPCategoryGroup *fpCategoryGroup = self.elements[collectionView.tag];
    [mutableArrayLock unlock];
    if (fpCategoryGroup.groupType == kCategoriesOnlyGroup) {
        return fpCategoryGroup.items.count;
    } else {
        return 0;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLock *mutableArrayLock = [[NSLock alloc] init];
    [mutableArrayLock lock];
    FPCategoryGroup *fpCategoryGroup = self.elements[collectionView.tag];
    [mutableArrayLock unlock];
    CategoryGroupType groupType = fpCategoryGroup.groupType;
    if (groupType == kCategoriesOnlyGroup) {
        if (self.fpDatasourceDelegate && [self.fpDatasourceDelegate respondsToSelector:@selector(didSelectItemAndShouldPushViewController:)]) {
            CategoriesData *cData = (CategoriesData *)fpCategoryGroup.items[indexPath.row];
            RestaurantListViewController *restaurantLVC = [[RestaurantListViewController alloc] initWithCategoryData:cData];
            [self.fpDatasourceDelegate didSelectItemAndShouldPushViewController:restaurantLVC];
        }
    }
}

- (void)didSelectRestaurantAndShouldPushRestaurantWithObjectId:(NSString *)objectId {
    if ((self.fpDatasourceDelegate && [self.fpDatasourceDelegate respondsToSelector:@selector(didSelectItemAndShouldPushViewController:)])) {
        RestaurantViewController *restaurantVC = [[RestaurantViewController alloc] initWithNibName:@"RestaurantViewController" bundle:nil andParseObjectId:objectId];
        [self.fpDatasourceDelegate didSelectItemAndShouldPushViewController:restaurantVC];
    }
}

@end
