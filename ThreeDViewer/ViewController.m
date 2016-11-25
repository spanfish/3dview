//
//  ViewController.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 9/26/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "ViewController.h"
#import "ThreeDModelViewController.h"

@interface ViewController () {
    NSMutableArray<NSString *> *_modelArray;
}

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 50;
    self.title = @"3D Models";

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"3DV"] == FALSE) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:nil];
            
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSError *error = nil;
            for (NSString *file in files) {
                NSLog(@"%@", file);
                if([file hasSuffix:@".obj"] || [file hasSuffix:@".mtl"] || [file hasSuffix:@".tga"]|| [file hasSuffix:@".dds"]) {
                    [[NSFileManager defaultManager] copyItemAtPath:[resourcePath stringByAppendingPathComponent:file]
                                                            toPath:[documentsDirectory stringByAppendingPathComponent:file]
                                                             error:&error];
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"3DV"];
            [self loadFiles:nil];
        });
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFiles:nil];
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    
    // 年月日をとりだす
    comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay)
                        fromDate:date];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    if(year >= 2016 && month >= 10 && day >= 22) {
        if(!self.banner) {
            self.banner = [[IMBanner alloc] initWithFrame:CGRectMake(0, 0, 320, 50) placementId:1477525435353 delegate:self];
            [self.bannerContainer addSubview:self.banner];
        }
        [self.banner load];
    }
}

-(IBAction)loadFiles:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.xiang.3dviewer"];
        containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches"];
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:containerURL.path error:nil]) {
            NSError *error = nil;
            NSInteger i = 0;
            NSString *newFileName = file;
            NSString *baseName = [file stringByDeletingPathExtension];
            while ([[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:newFileName] isDirectory:nil]) {
                i++;
                newFileName = [NSString stringWithFormat:@"%@_%ld.obj", baseName, i];
            }

//            [[NSFileManager defaultManager] copyItemAtPath:[containerURL.path stringByAppendingPathComponent:file]
//                                                    toPath:[documentsDirectory stringByAppendingPathComponent:newFileName]
//                                                     error:&error];
            [[NSFileManager defaultManager] moveItemAtPath:[containerURL.path stringByAppendingPathComponent:file]
                                                    toPath:[documentsDirectory stringByAppendingPathComponent:newFileName]
                                                     error:&error];
            if(error) {
                NSLog(@"%@", error);
            }
//            [[NSFileManager defaultManager] removeItemAtPath:[containerURL.path stringByAppendingPathComponent:file] error:&error];
//            if(error) {
//                NSLog(@"%@", error);
//            }
        }
        
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
        NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[files count]];
        for (NSString *file in files) {
            //NSLog(@"%@", file);
            if([[file lowercaseString] hasSuffix:@".obj"]) {
                [tmpArray addObject:[documentsDirectory stringByAppendingPathComponent:file]];
            }
        }
        _modelArray = tmpArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_modelArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShowModel"];
    NSString *path = [_modelArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [path lastPathComponent];
    cell.imageView.image = [UIImage imageNamed:@"obj.png"];
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *path = [_modelArray objectAtIndex:indexPath.row];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if(!error) {
            [_modelArray removeObjectAtIndex:indexPath.row];
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    }
}
#pragma mark -
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowModel"]) {
        ThreeDModelViewController *viewController = segue.destinationViewController;
        //
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSString *path = [_modelArray objectAtIndex:indexPath.row];
        viewController.modelPath = path;
    }
}

#pragma mark -
/**
 * Notifies the delegate that the banner has finished loading
 */
-(void)bannerDidFinishLoading:(IMBanner*)banner {
    self.adTopConstrait.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
/**
 * Notifies the delegate that the banner has failed to load with some error.
 */
-(void)banner:(IMBanner*)banner didFailToLoadWithError:(IMRequestStatus*)error {
    self.adTopConstrait.constant = -50;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
/**
 * Notifies the delegate that the banner was interacted with.
 */
-(void)banner:(IMBanner*)banner didInteractWithParams:(NSDictionary*)params {
    
}
/**
 * Notifies the delegate that the user would be taken out of the application context.
 */
-(void)userWillLeaveApplicationFromBanner:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the banner would be presenting a full screen content.
 */
-(void)bannerWillPresentScreen:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the banner has finished presenting screen.
 */
-(void)bannerDidPresentScreen:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the banner will start dismissing the presented screen.
 */
-(void)bannerWillDismissScreen:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the banner has dismissed the presented screen.
 */
-(void)bannerDidDismissScreen:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the user has completed the action to be incentivised with.
 */
-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    
}
@end
