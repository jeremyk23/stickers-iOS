//
//  FrontPageCategoryData.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/28/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

//// #import <Foundation/Foundation.h>
#import "AFTableViewCell.h"
#import "FrontPageDataSource.h"
#import "Helpers.h"
#import <Parse/Parse.h>

@interface FrontPageCategoryData : NSObject

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView representationAsCellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
