//
//  ShareViewController.m
//  Save To 3D Viewer
//
//  Created by xiangwei wang on 2016/10/27.
//  Copyright © 2016年 xiangwei wang. All rights reserved.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

@end

@implementation ShareViewController
-(void) viewDidLoad {
    [super viewDidLoad];
    self.title = @"Save to 3D Viewer";
}
- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    for(NSExtensionItem *item in self.extensionContext.inputItems) {
        for(NSItemProvider *provider in item.attachments) {
            if([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [provider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    NSLog(@"item:%@", item);
                    NSURL *url = (NSURL *) item;
                    
                    NSError *e = nil;
                    NSString *string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&e];
                    if(e) {
                        NSLog(@"error:%@", e);
                    } else {
                        NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.xiang.3dviewer"];
                        containerURL = [[containerURL URLByAppendingPathComponent:@"Library/Caches"] URLByAppendingPathComponent:[url lastPathComponent]];
                        [string writeToURL:containerURL atomically:YES encoding:NSUTF8StringEncoding error:&e];
                        if(e) {
                            NSLog(@"error:%@", e);
                            
                        } else {
                            
                        }
                    }
                }];
            } else if([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
                [provider loadItemForTypeIdentifier:(NSString *)kUTTypeFileURL options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    NSLog(@"item:%@", item);
                    
                    NSURL *url = (NSURL *) item;
                    
                    NSError *e = nil;
                    NSString *string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&e];
                    if(e) {
                        NSLog(@"error:%@", e);
                    } else {
                        NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.xiang.3dviewer"];
                        containerURL = [[containerURL URLByAppendingPathComponent:@"Library/Caches"] URLByAppendingPathComponent:[url lastPathComponent]];
                        [string writeToURL:containerURL atomically:YES encoding:NSUTF8StringEncoding error:&e];
                        if(e) {
                            NSLog(@"error:%@", e);
                            
                        } else {
                            
                        }
                    }
                    
                }];
            } else if([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
                [provider loadItemForTypeIdentifier:(NSString *)kUTTypeText options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    NSLog(@"item:%@", item);
                }];
            }
        }
        NSLog(@"");
    }
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
