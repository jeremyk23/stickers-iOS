//
//  AFTableViewCell.h
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBLabel.h"

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface AFTableViewCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *transparencyView;
@property (nonatomic, strong) BBLabel *categoryLabel;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
