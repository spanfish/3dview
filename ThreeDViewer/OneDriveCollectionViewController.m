//
//  OneDriveCollectionViewController.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/8/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "OneDriveCollectionViewController.h"
#import "OneDriveCollectionViewCell.h"
#import "MBProgressHUD.h"

#define APP_ID @"49dfc6b1-922e-40c3-90d1-3908c39c4e7f"
static void *ProgressObserverContext = &ProgressObserverContext;

@interface OneDriveCollectionViewController ()
@property (strong, nonatomic) MBProgressHUD *HUD;
@end

@implementation OneDriveCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cloud.png"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(downloadItems)];
    [item setEnabled:NO];
    [self setToolbarItems:@[space, item] animated:YES];
    
    [self.navigationController setToolbarHidden:NO animated:TRUE];
    self.items = [NSMutableDictionary dictionary];
    self.itemsLookup = [NSMutableArray array];
    self.thumbnails = [NSMutableDictionary dictionary];
    self.selectedItems = [NSMutableArray array];
    if(self.currentItem == nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(doneTouched:)];
    }
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    [ODClient setMicrosoftAccountAppId:APP_ID scopes:@[@"onedrive.readonly", @"offline_access"] ];
    
    // Register cell classes
//    [self.collectionView registerClass:[OneDriveCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.HUD = [[MBProgressHUD alloc] initWithView: self.view];
    self.HUD.label.text = @"Loading...";
    [self.view addSubview:self.HUD];
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.HUD showAnimated:TRUE];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ODClient clientWithCompletion:^(ODClient *client, NSError *error){
            if (!error){
                self.client = client;
                [self loadChildren];
            }
        }];
    });
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.itemsLookup count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OneDriveCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    ODItem *item = [self itemForIndex:indexPath];

    // Reset the old image
    cell.checkImageView.image = nil;
    cell.imageView.image = nil;
    cell.titleLabel.textColor = [UIColor blueColor];
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    [cell.titleLabel setText:item.name];

    if (item.folder){
        cell.imageView.image = [UIImage imageNamed:@"folder.png"];
        cell.titleLabel.textColor = [UIColor whiteColor];
    }
    
    if ([self.selectedItems containsObject:item]){
        cell.selected = YES;
        cell.checkImageView.image = [UIImage imageNamed:@"check.png"];
    }
    if (self.thumbnails[item.id]){
        UIImage *image = self.thumbnails[item.id];
        cell.imageView.image = image;
    } else if([[[item.name pathExtension] lowercaseString] isEqualToString:@"obj"]){
        cell.imageView.image = [UIImage imageNamed:@"obj.png"];
    }


    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __block ODItem *item = [self itemForIndex:indexPath];
    if (item.folder){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.navigationController pushViewController:[self collectionViewWithItem:item] animated:YES];
        });
    }
    else if (item.file){
        if ([self.selectedItems containsObject:item]){
            [self.selectedItems removeObject:item];
        }
        else{
            [self.selectedItems addObject:item];
        }
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        UIBarButtonItem *item = [self.toolbarItems objectAtIndex:1];
        [item setEnabled:[self.selectedItems count] > 0];
    }
}

-(void) downloadItems {
    
    if([self.selectedItems count] > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeDeterminate;
        hud.removeFromSuperViewOnHide = YES;
        [self downloadFileAtIndex: 0];
    }
}

-(void) downloadFileAtIndex:(int) index {
    if(index > [self.selectedItems count] - 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Set the determinate mode to show task progress.
            [MBProgressHUD HUDForView:self.view].label.text = @"Finished";
            [[MBProgressHUD HUDForView:self.view] hideAnimated:TRUE afterDelay:1];
        });
        return;
    }
    ODItem *item = [self.selectedItems objectAtIndex:index];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Set the determinate mode to show task progress.
        [MBProgressHUD HUDForView:self.view].label.text = [NSString stringWithFormat:@"Downloading %@", item.name];
    });
    
    ODURLSessionDownloadTask *task = [[[[self.client drive] items:item.id] contentRequest] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if(!error) {
            NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *newFilePath = [documentPath stringByAppendingPathComponent:item.name];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:newFilePath] error:nil];
            
            [self downloadFileAtIndex:index + 1];
        } else {
            [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
        }
    }];
    [task.progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:0 context:ProgressObserverContext];
    task.progress.totalUnitCount = item.size;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSProgress *progress = object;
            double fractionCompleted = progress.fractionCompleted;
            [MBProgressHUD HUDForView:self.view].progress = fractionCompleted;
        });
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (OneDriveCollectionViewController *)collectionViewWithItem:(ODItem *)item;
{
    OneDriveCollectionViewController *newController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OneDriveCollectionView"];
    newController.title = item.name;
    newController.currentItem = item;
    newController.client = self.client;
    return newController;
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark -
- (ODItem *)itemForIndex:(NSIndexPath *)indexPath
{
    NSString *itemId = self.itemsLookup[indexPath.row];
    return self.items[itemId];
}

- (void)loadChildren {
    NSString *itemId = (self.currentItem) ? self.currentItem.id : @"root";
    ODChildrenCollectionRequest *childrenRequest = [[[[self.client drive] items:itemId] children] request];
    if (![self.client serviceFlags][@"NoThumbnails"]){
        [childrenRequest expand:@"thumbnails"];
    }
    [self loadChildrenWithRequest:childrenRequest];
}

- (void)loadChildrenWithRequest:(ODChildrenCollectionRequest*)childrenRequests
{
    [childrenRequests getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.HUD hideAnimated:YES];
        });
        if (!error){
            if (response.value){
                [self onLoadedChildren:response.value];
            }
            if (nextRequest){
                [self loadChildrenWithRequest:nextRequest];
            }
        }
        else if ([error isAuthenticationError]){
            //[self showErrorAlert:error];
            [self onLoadedChildren:@[]];
        }
    }];
}

- (void)onLoadedChildren:(NSArray *)children
{
    //    if (self.refreshControl.isRefreshing){
    //        [self.refreshControl endRefreshing];
    //    }
    [children enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
        if (![self.itemsLookup containsObject:item.id]){
            [self.itemsLookup addObject:item.id];
        }
        self.items[item.id] = item;
    }];
    [self loadThumbnails:children];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.collectionView reloadData];
    });
}

- (void)loadThumbnails:(NSArray *)items{
    for (ODItem *item in items){
        if ([item thumbnails:0]){
            [[[[[[self.client drive] items:item.id] thumbnails:@"0"] small] contentRequest] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                if (!error){
                    self.thumbnails[item.id] = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [self.collectionView reloadData];
                    });
                }
            }];
        }
    }
}

-(IBAction)doneTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
