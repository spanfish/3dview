//
//  AppDelegate.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 9/26/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "AppDelegate.h"
#import <GLKit/GLKit.h>
#import <AmazonAd/AmazonAdRegistration.h>
#import "ViewController.h"
#define AMZON_KEY @"6af082f4091445b288d0271bac6f8bbb"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [IMSdk initWithAccountID:@"7a16cd61264446cf98e43bbebd7c61ac"];
    [[AmazonAdRegistration sharedRegistration] setAppKey:AMZON_KEY];
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
    UINavigationController *nvc = (UINavigationController*)[self.window rootViewController];
    ViewController *vc = (ViewController*)[nvc.viewControllers firstObject];
    [vc loadFiles:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //Check for orphaned files in the inbox
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if([[url scheme] isEqualToString:@"objmodel"]) {
        [self openModel];
    } else
    if (url) {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSURL *localURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent: [url.path lastPathComponent]]];
        [[NSFileManager defaultManager] moveItemAtURL:url toURL:localURL error:nil];
        UINavigationController *nvc = (UINavigationController*)[self.window rootViewController];
        ViewController *vc = (ViewController*)[nvc.viewControllers firstObject];
        [vc loadFiles:nil];
        
    }
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSLog(@"url:%@", url);
    [self openModel];
    return YES;
}

-(void) openModel {
    
}
#pragma mark - Document Inbox Handling

- (void)handleDocumentsInbox
{
    NSLog(@"");
    //All incoming files are stored in Documents/Inbox/
//    NSString *inboxPath = [[APLUtilities documentsDirectory] stringByAppendingPathComponent:kDocumentsInboxFolder];
//    
//    NSFileManager *fileManager = [[NSFileManager alloc] init];
//    NSArray *inboxFiles = [fileManager contentsOfDirectoryAtPath:inboxPath error:nil];
//    
//    for (NSString *path in inboxFiles) {
//        
//        //Append file name to path and create URL
//        NSURL *url = [NSURL fileURLWithPath:[inboxPath stringByAppendingPathComponent:path]];
//        [self application:[UIApplication sharedApplication] openURL:url sourceApplication:@"" annotation:nil];
//    }
}
@end
