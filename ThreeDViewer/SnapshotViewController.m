//
//  SnapshotViewController.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/8/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "SnapshotViewController.h"
#import "ImageUtils.h"

#import <AmazonAd/AmazonAdError.h>

@interface SnapshotViewController ()

@end

@implementation SnapshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = _snapshot;
    self.interstitial = [AmazonAdInterstitial amazonAdInterstitial];
    self.interstitial.delegate = self;
    AmazonAdOptions *options = [AmazonAdOptions options];
#if DEBUG
    options.isTestRequest = YES;
#else
    options.isTestRequest = NO;
#endif
    [self.interstitial load:options];
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

-(IBAction)shareTouched:(id)sender {
    UIActivityViewController *svc = [[UIActivityViewController alloc] initWithActivityItems:@[[ImageUtils drawText:@"Find \"obj 3D Model Viewer\" at Appstore" atBottomInImage:_snapshot]] applicationActivities:nil];
    svc.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:svc animated:YES completion:^{
    }];
}
-(IBAction)doneTouched:(id)sender {
    if(self.interstitial.isReady) {
        [self.interstitial presentFromViewController:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark AmazonAdInterstitialDelegate
- (void)interstitialDidLoad:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstial loaded.");
}

- (void)interstitialDidFailToLoad:(AmazonAdInterstitial *)interstitial withError:(AmazonAdError *)error
{
    NSLog(@"Interstitial failed to load.");
}

- (void)interstitialWillPresent:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstitial will be presented.");
}

- (void)interstitialDidPresent:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstitial has been presented.");
}

- (void)interstitialWillDismiss:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstitial will be dismissed.");
}

- (void)interstitialDidDismiss:(AmazonAdInterstitial *)interstitial
{
    NSLog(@"Interstitial has been dismissed.");
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
