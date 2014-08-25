//
//  RestaurantViewController.h
//  Entree
//
//  Created by Jeremy Klein Sr on 7/4/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ERequestInterface.h"
#import "EFoursquareParser.h"
@class PFObject;
@class PFImageView;
@class BBLabel;

@interface RestaurantViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ERequestInterfaceDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) ERequestInterface *request;
@property (weak, nonatomic) IBOutlet BBLabel *addressLabel;
@property (weak, nonatomic) IBOutlet BBLabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *photoGallery;

//@property (weak, nonatomic) IBOutlet PFImageView *restaurantPhoto;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PFObject *restaurant;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPFObject:(PFObject *)restaurant;

@end
