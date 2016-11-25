//
//  ActionViewController.m
//  Open In 3D Viewer
//
//  Created by xiangwei wang on 2016/10/27.
//  Copyright © 2016年 xiangwei wang. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()
@property(nonatomic, strong) IBOutlet UILabel *msgLabel;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;
@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if([itemProvider hasItemConformingToTypeIdentifier:(NSString *) kUTTypeHTML]) {
                NSLog(@"kUTTypeText");
            } else
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                // This is an image. We'll load it, then place it in our image view.
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *item, NSError *error) {

                    NSError *e = nil;
                    NSString *string = [NSString stringWithContentsOfURL:item encoding:NSUTF8StringEncoding error:&e];
                    if(e) {
                        NSLog(@"error:%@", e);
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            self.msgLabel.text = @"Failed to saving model data";
                            [self.indicatorView stopAnimating];
                        });
                        
                    } else {
//                        NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.xiang.3dviewer"];
//                        NSArray *array = [mySharedDefaults arrayForKey:@"Models"];
//                        NSMutableArray *tmp = [NSMutableArray arrayWithArray:array];
//                        [tmp addObject:string];
//                        [mySharedDefaults setObject:tmp forKey:@"Models"];
//                        
//                        NSMutableArray *nameArray = [NSMutableArray arrayWithArray:[mySharedDefaults arrayForKey:@"ModelNames"]];
//                        [nameArray addObject:[[item absoluteString] lastPathComponent]];
//                        [mySharedDefaults setObject:nameArray forKey:@"ModelNames"];
//                        [mySharedDefaults synchronize];
                        NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.xiang.3dviewer"];
                        containerURL = [[containerURL URLByAppendingPathComponent:@"Library/Caches"] URLByAppendingPathComponent:[item lastPathComponent]];
                        [string writeToURL:containerURL atomically:YES encoding:NSUTF8StringEncoding error:&e];
                        if(e) {
                            NSLog(@"error:%@", e);
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                self.msgLabel.text = @"Failed to saving model data";
                                [self.indicatorView stopAnimating];
                            });
                        } else {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            self.msgLabel.text = @"Model data saved sucessfully,\nopen 3D Viewer app to view";
                            [self.indicatorView stopAnimating];
                        });
                        }
                    }
                    
                    NSLog(@"URL:%@, error:%@", item, error);
                }];
                break;
            }
        }
    }
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
