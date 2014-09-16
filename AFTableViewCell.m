//
//  AFTableViewCell.m
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "AFTableViewCell.h"
#import "RestaurantCategoryCollectionViewCell.h"

@implementation AFTableViewCell

- (id)initWithOutCollectionViewAndWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.categoryLabel.alpha = 0.0f;
    self.transparencyView.alpha = 0.0f;
    return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
//    layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
    layout.itemSize = CGSizeMake(320.0f, 245.0f);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView setPagingEnabled:YES];
    self.categoryLabel.alpha = 0.0f;
    self.transparencyView.alpha = 0.0f;
    [self.contentView addSubview:self.collectionView];
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
}

- (void)displayCategoryLabel {
    if (!self.categoryLabel) {
        self.transparencyView = [[UIView alloc] init];
        self.transparencyView.frame = CGRectMake(0.0f, 190.0f, 320.0f, 55.0f);
        self.transparencyView.backgroundColor = [UIColor colorWithRed:94.0f/255.0f green:164.0f/255.0f blue:174.0f/255.0f alpha:0.0f];
        [self addSubview:self.transparencyView];
        
        self.categoryLabel = [[BBLabel alloc] init];
        self.categoryLabel.frame = CGRectMake(0.0f, 212.0f, 320.0f, 30.0f);
        self.categoryLabel.textColor = [UIColor whiteColor];
        self.categoryLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.categoryLabel];
        
        
    }
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.categoryLabel setAlpha:1.0];
                         self.transparencyView.backgroundColor = [UIColor colorWithRed:94.0f/255.0f green:164.0f/255.0f blue:174.0f/255.0f alpha:0.75f];
                     }
                     completion:^(BOOL finished) {
                         // Completion Block
                     }];
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = index;
    
    [self.collectionView reloadData];
}

@end
