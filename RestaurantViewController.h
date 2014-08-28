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
#import "StickersCollectionView.h"
@class PFObject;
@class PFImageView;
@class BBLabel;
@class MKMapView;


@interface RestaurantViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ERequestInterfaceDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StickersCollectionViewDelegate>

@property (nonatomic, strong) ERequestInterface *request;
@property (weak, nonatomic) IBOutlet UIView *infoBackdropView;
@property (weak, nonatomic) IBOutlet BBLabel *addressLabel;
@property (weak, nonatomic) IBOutlet BBLabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *restaurantLogo;
@property (weak, nonatomic) IBOutlet UICollectionView *photoGallery;
@property (weak, nonatomic) IBOutlet StickersCollectionView *stickersGridView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickerGridViewHeight;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//@property (weak, nonatomic) IBOutlet PFImageView *restaurantPhoto;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PFObject *restaurant;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPFObject:(PFObject *)restaurant;

@end
