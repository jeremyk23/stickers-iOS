//
//  AppDelegate.m
//  Best Bites
//
//  Created by Jeremy Klein Sr on 7/12/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "AFViewController.h"
#import <Parse/Parse.h>

@interface AppDelegate ()
            

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [Parse setApplicationId:@"ORu5DTWq9gk7DYBNKb9SDlni9FiKkfyYBFee99YM"
                  clientKey:@"8PbGArQdZxbid29sDoI6bF7IFzODvbicQHDCRh3K"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    AFViewController *homeVC = [[AFViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:homeVC];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:14.0f/255.0f green:166.0f/155.0f blue:169.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:12.0f/255.0f green:146.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"GillSans" size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName, nil]];
//    self.navigationController.navigationBar.translucent = NO;
    self.window.rootViewController = self.navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
