//
//  SearchViewController.m
//  Best Bites
//
//  Created by Jeremy Klein Sr on 7/19/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "SearchViewController.h"
#import "ERequestInterface.h"
#import "EFoursquareParser.h"
#import <Parse/Parse.h>
#import "RestaurantViewController.h"
#import "FoursquareRestaurantViewController.h"

@interface SearchViewController () <ERequestInterfaceDelegate>

@property (nonatomic, strong) ERequestInterface *request;
@property (nonatomic) BOOL userQueryData;
@property (nonatomic, strong) NSArray *searchSuggestionsSubset;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation SearchViewController
@synthesize userQueryData;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        userQueryData = FALSE;
        self.request = [[ERequestInterface alloc] init];
        self.request.eDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *searchIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchFoursquare:)];
    searchIcon.title = @"Search";
    self.navigationItem.rightBarButtonItem = searchIcon;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem *cancelIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBackToHomeView)];
    cancelIcon.title = @"cancel";
    self.navigationItem.leftBarButtonItem = cancelIcon;
    
    self.searchSuggestionsSubset = [self createSearchSuggestions];
    self.dataSource = [NSArray arrayWithArray:self.searchSuggestionsSubset];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource != 0) {
        return self.dataSource.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *restaurantCellIdentifier = @"restaurantCell";
    static NSString *suggestionCellIdentifier = @"suggestionCell";
    UITableViewCell *cell;
    if (userQueryData) {
        cell = [tableView dequeueReusableCellWithIdentifier:restaurantCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:restaurantCellIdentifier];
        }
        cell.textLabel.text = self.dataSource[indexPath.row][@"venue"][@"name"];
        cell.detailTextLabel.text = self.dataSource[indexPath.row][@"venue"][@"categories"][0][@"name"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:suggestionCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:suggestionCellIdentifier];
        }
        cell.textLabel.text = self.dataSource[indexPath.row];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (userQueryData) {
        NSString *foursquareId = self.dataSource[indexPath.row][@"venue"][@"id"];
        PFQuery *queryForMatchingRestaurant = [PFQuery queryWithClassName:@"Restaurant"];
        [queryForMatchingRestaurant whereKey:@"foursquareId" equalTo:foursquareId];
        NSArray *match = [queryForMatchingRestaurant findObjects];
        RestaurantViewController *restaurantVC;
        if (match.count == 0) {
            restaurantVC = [[FoursquareRestaurantViewController alloc] initWithNibName:@"RestaurantViewController" bundle:nil andFsID:foursquareId];
        } else {
            restaurantVC = [[RestaurantViewController alloc] initWithNibName:@"RestaurantViewController" bundle:nil andPFObject:match[0]];
        }
        [self.navigationController pushViewController:restaurantVC animated:YES];
    } else {
        [self searchFoursquare:self.dataSource[indexPath.row]];
    }
}

- (void)searchFoursquare:(NSString *)query {
    self.userQueryData = TRUE;
    [self.request searchNearbyRestaurantsWithQuery:query andLocality:@"portland,OR"];
}

- (void)didFinishLoadingFoursquare:(NSDictionary *)response {
    self.dataSource = [EFoursquareParser returnRestaurantsArray:response];
    userQueryData = TRUE;
    [self.tableView reloadData];
}

- (void)didFailWithError:(NSError *)error {
    NSLog(@"Failed getting foursquare data with error: %@", error);
}

- (void)goBackToHomeView {
    [UIView animateWithDuration:0.35
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController popToRootViewControllerAnimated:YES];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }];
    
}

- (NSArray *)createSearchSuggestions {
    NSArray *searchSuggestions = [[NSArray alloc] initWithObjects:@"Indian", @"Italian", @"African", @"Chinese", @"Korean", @"Barbeque", @"Comfort", @"Deli", @"Brunch", @"American", @"Burger", @"Healthy", @"Salad", @"Mediterranean", @"Ethiopian", @"German", nil];
    NSMutableArray *subsetSuggestions = [[NSMutableArray alloc] initWithCapacity:10];
    //grab random, subset of unique objects
    for (NSUInteger i = 0; i < 10; ++i) {
        NSNumber *ri = [NSNumber numberWithInteger: arc4random_uniform((unsigned int)searchSuggestions.count)];
        while ([subsetSuggestions indexOfObject:ri] != NSNotFound) {
            ri = [NSNumber numberWithInteger: arc4random_uniform((unsigned int)searchSuggestions.count)];
        }
        [subsetSuggestions addObject:searchSuggestions[[ri integerValue]]];
    }
    return (NSArray *)subsetSuggestions;
}

- (void)switchDataSourceToSuggestions {
    self.dataSource = self.searchSuggestionsSubset;
    self.userQueryData = FALSE;
    [self.tableView reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar2 {
    [self.searchBar setShowsCancelButton:YES];
    for (UIView *subview in self.searchBar.subviews) {
        for (UIView *subSubview in subview.subviews) {
            if ([subSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
                UITextField *textField = (UITextField *)subSubview;
                if ([searchBar2.text isEqualToString:@""]) {
                    [textField setKeyboardAppearance: UIKeyboardAppearanceDefault];
                    [textField setEnablesReturnKeyAutomatically:NO];
                    textField.returnKeyType = UIReturnKeyDone;
                } else {
                    [textField setKeyboardAppearance: UIKeyboardAppearanceDefault];
                }
            }
        }
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //[self searchFoursquareWithQuery:searchBar.text];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self switchDataSourceToSuggestions];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar2 {
    if (![searchBar2.text isEqualToString:@""]) {
        [self searchFoursquare:searchBar2.text];
    }
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    for (UIView *subview in self.searchBar.subviews) {
        for (UIView *subSubview in subview.subviews) {
            if ([subSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
                UITextField *textField = (UITextField *)subSubview;
                [textField setKeyboardAppearance: UIKeyboardAppearanceDefault];
                textField.returnKeyType = UIReturnKeySearch;
            }
        }
    }
    [self searchFoursquare:searchText];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
