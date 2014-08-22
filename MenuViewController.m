//
//  MenuViewController.m
//  Entree
//
//  Created by Jeremy Klein Sr on 7/6/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "MenuViewController.h"
#import "ERequestInterface.h"
#import "EFoursquareParser.h"
#import "MenuItemTableViewCell.h"
#import "ELocuParser.h"
#import "BBLabel.h"
#import "Constants.h"
#import "Menu.h"

@interface MenuViewController () <ERequestInterfaceDelegate>
@property (nonatomic, strong) ERequestInterface *request;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSString *foursquareId;
@property (nonatomic, strong) NSString *parseId;
@property (nonatomic, strong) NSString *locuId;
@property (nonatomic) BOOL menuOnLocu;

// A dictionary of offscreen cells that are used within the tableView:heightForRowAtIndexPath: method to
// handle the height calculations. These are never drawn onscreen. The dictionary is in the format:
//      { NSString *reuseIdentifier : UITableViewCell *offscreenCell, ... }
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@property (nonatomic, strong) Menu *menu;
@property (nonatomic) NSUInteger currentMenu;
@end

@implementation MenuViewController
@synthesize currentMenu;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.request = [[ERequestInterface alloc] init];
        self.request.eDelegate = self;
        self.offscreenCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)storeFoursquareId:(NSString *)foursquareId parseId:(NSString *)parseId restaurantName:(NSString *)restaurantName andLocuId:(NSString *)locuId {
    self.foursquareId = foursquareId;
    self.parseId = parseId;
    self.restaurantName = restaurantName;
    self.locuId = locuId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.segmentedControlMenu removeAllSegments];
    if ([self.locuId isEqual:@""] || self.locuId == nil) {
        [self.request requestMenuData:self.foursquareId];
    } else {
        [self.request requestLocuMenuWithVenueID:self.locuId];
    }
    
    // Setting the estimated row height prevents the table view from calling tableView:heightForRowAtIndexPath: for every row in the table on first load;
    // it will only be called as cells are about to scroll onscreen. This is a major performance optimization.
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    self.currentMenu = 0;
    self.restaurantNameLabel.text = self.restaurantName;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

// This method is called when the Dynamic Type user setting changes (from the system Settings app)
- (void)contentSizeCategoryChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)didFinishLoadingFoursquare:(NSDictionary *)response {
    if (response[@"menu"]) {
        EFoursquareParser *parser = [[EFoursquareParser alloc] init];
        self.menu = [parser getFormattedEMenuObject:response];
        [self refreshTableIfDataIsAvailable];
    }
}

- (void)didFinishLoadingLocu:(NSDictionary *)response {
    ELocuParser *parser = [[ELocuParser alloc] init];
    self.menu = [parser getFormattedEMenuObject:response];
    [self refreshTableIfDataIsAvailable];
}

- (void)didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)refreshTableIfDataIsAvailable {
    if (self.menu) {
        [self.segmentedControlMenu removeAllSegments];
        for (NSUInteger i = 0; i < self.menu.arrayOfMenus.count; i++) {
            [self.segmentedControlMenu insertSegmentWithTitle:self.menu.arrayOfMenus[i][@"menuName"] atIndex:i animated:YES];
        }
        self.segmentedControlMenu.selectedSegmentIndex = currentMenu;
        [self.tableView reloadData];
    } else {
        [self alertNoMenuDataFound];
    }
}

- (void)alertNoMenuDataFound {
    UIView *noMenuView = [[UIView alloc] initWithFrame:self.tableView.frame];
    [self.view addSubview:noMenuView];
    [self.view bringSubviewToFront:noMenuView];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Menu Data Unavailable" message:@"We're sorry! Menu data for this restaurant is currently unavailable." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [alertView show];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.menu.arrayOfMenus.count != 0) {
        return [self.menu.arrayOfMenus[currentMenu][kMenu_menuArray] count];
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.menu.arrayOfMenus.count != 0) {
        return [self.menu.arrayOfMenus[currentMenu][kMenu_menuArray][section] count];
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.menu.arrayOfMenus.count != 0) {
        Menu_SectionTitle *sectionTitle = (Menu_SectionTitle *)self.menu.arrayOfMenus[currentMenu][kMenu_sectionArray][section];
        return sectionTitle.sectionTitle;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Menu_MenuType *menuItem = (Menu_MenuType *)self.menu.arrayOfMenus[currentMenu][kMenu_menuArray][indexPath.section][indexPath.row];
    return [menuItem tableView:tableView representationAsCellForRowAtIndexPath:indexPath];
}
- (IBAction)didChangeMenuType:(id)sender {
    NSUInteger selectedRestaurantIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    currentMenu = selectedRestaurantIndex;
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This project has only one cell identifier, but if you are have more than one, this is the time
    // to figure out which reuse identifier should be used for the cell at this index path.
    Menu_MenuType *menuType = (Menu_MenuType *)self.menu.arrayOfMenus[currentMenu][kMenu_menuArray][indexPath.section][indexPath.row];
    NSString *reuseIdentifier = [menuType cellIdentifier];
    
    // Use the dictionary of offscreen cells to get a cell for the reuse identifier, creating a cell and storing
    // it in the dictionary if one hasn't already been added for the reuse identifier.
    // WARNING: Don't call the table view's dequeueReusableCellWithIdentifier: method here because this will result
    // in a memory leak as the cell is created but never returned from the tableView:cellForRowAtIndexPath: method!
    MenuItemTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [[MenuItemTableViewCell alloc] init];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    // Configure the cell for this indexPath
//    [cell updateFonts];
    //This sucks.... sigh...If only I could drop iOS7 compatibility
    if ([menuType isMemberOfClass:[Menu_SectionDescr class]]) {
        Menu_SectionDescr *sectionDescription = (Menu_SectionDescr *)menuType;
        cell.bodyLabel.font = [UIFont fontWithName:@"GillSans-LightItalic" size:16.0];
        cell.bodyLabel.textAlignment = NSTextAlignmentCenter;
        cell.bodyLabel.text = sectionDescription.sectionDescription;
    } else if ([menuType isMemberOfClass:[Menu_Dish class]]) {
        Menu_Dish *menuDish = (Menu_Dish *)menuType;
        cell.textLabel.text = menuDish.dishName;
        cell.textLabel.font = [UIFont fontWithName:@"GillSans-Light" size:14.0f];
    } else if ([menuType isMemberOfClass:[Menu_DishWithDescr class]]) {
        Menu_DishWithDescr *menuDishWithDescr = (Menu_DishWithDescr *)menuType;
        cell.titleLabel.text = menuDishWithDescr.dishName;
        cell.bodyLabel.text = menuDishWithDescr.dishDescription;
    }
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    // The cell's width must be set to the same size it will end up at once it is in the table view.
    // This is important so that we'll get the correct height for different table view widths, since our cell's
    // height depends on its width due to the multi-line UILabel word wrapping. Don't need to do this above in
    // -[tableView:cellForRowAtIndexPath:] because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    // NOTE: if you are displaying a section index (e.g. alphabet along the right side of the table view), or
    // if you are using a grouped table view style where cells have insets to the edges of the table view,
    // you'll need to adjust the cell.bounds.size.width to be smaller than the full width of the table view we just
    // set it to above. See http://stackoverflow.com/questions/3647242 for discussion on the section index width.
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1;
    
    return height;
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end