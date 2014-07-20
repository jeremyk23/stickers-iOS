//
//  HomeViewController.m
//  Best Bites
//
//  Created by Jeremy Klein Sr on 7/12/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "HomeViewController.h"
#import "FrontPageRestaurantsQTVC.h"
#import "SearchViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *searchIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(presentSearchViewController)];
    self.navigationItem.rightBarButtonItem = searchIcon;
    self.navigationItem.title = @"Best Bites";
    
    FrontPageRestaurantsQTVC *frontPageRestaurantsQTVC = [[FrontPageRestaurantsQTVC alloc] initWithStyle:UITableViewStylePlain];
    [self addChildViewController: frontPageRestaurantsQTVC];
    [self.view addSubview:frontPageRestaurantsQTVC.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentSearchViewController {
    SearchViewController *searchVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    [UIView animateWithDuration:0.35
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:searchVC animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
}


@end
