//
//  CategoriesData.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "CategoriesData.h"
#import "CategoryCollectionViewCell.h"


NSString static *categoriesCell = @"CategoriesCell";

@implementation CategoriesData

- (id)initWithCategoryObject:(PFObject *)category {
    self = [super init];
    if (self) {
        self.categoryPicture = category[@"categoryPicture"];
        self.categoryTitle = category[@"categoryName"];
        self.parseCategoryObjectId = category.objectId;
    }
    return self;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView representationAsCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CategoryCollectionViewCellIdentifier forIndexPath:indexPath];
    if (self.categoryPicture) {
        cell.categoryImage.file = self.categoryPicture;
        [cell.categoryImage loadInBackground:^(UIImage *image, NSError *error) {
            cell.categoryImage.image = [Helpers imageByScalingAndCroppingForSize:cell.categoryImage.frame.size withImage:image];
        }];
    cell.categoryImage.file = self.categoryPicture;
    [cell.categoryImage loadInBackground];
    cell.categoryNameLabel.text = self.categoryTitle;
    }
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView representationAsCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:categoriesCell];
    if (!cell) {
        cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:categoriesCell];
    }
    cell.textLabel.text = self.categoryTitle;
    cell.textLabel.font = [UIFont fontWithName:@"GillSans-Light" size:14.0f];
    return cell;
}

@end
