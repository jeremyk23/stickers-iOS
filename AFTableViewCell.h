//
//  AFTableViewCell.h
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBLabel.h"

@interface AFTableViewCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *transparencyView;
@property (nonatomic, strong) BBLabel *categoryLabel;

- (id)initWithOutCollectionViewAndWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)displayCategoryLabel;
-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
