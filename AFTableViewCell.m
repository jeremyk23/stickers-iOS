//
//  AFTableViewCell.m
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "AFTableViewCell.h"
#import "BBCategoryCell.h"

@implementation AFTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
//    layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
    layout.itemSize = CGSizeMake(320.0f, 245.0f);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"BBCategoryCell" bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView setPagingEnabled:YES];
    self.categoryLabel = [[BBLabel alloc] init];
    self.categoryLabel.frame = CGRectMake(0.0f, 212.0f, 320.0f, 30.0f);
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.categoryLabel];
//    self.transparencyView = [[UIView alloc] initWithFrame:CGRectMake(0, 190.0f, self.frame.size.width, 65.0f)];
//    self.transparencyView.backgroundColor = [UIColor colorWithRed:118/255.0f green:176/255.0f blue:182.0f/255.0f alpha:0.5];
//    [self.collectionView addSubview:self.transparencyView];
    
    [self.contentView addSubview:self.collectionView];
    
    

    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.contentView.bounds;
    
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = index;
    
    [self.collectionView reloadData];
}

@end
