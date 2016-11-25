//
//  SnapshotViewController.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/8/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AmazonAd/AmazonAdInterstitial.h>
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdError.h>

@interface SnapshotViewController : UIViewController<AmazonAdInterstitialDelegate>

@property(nonatomic, strong) UIImage *snapshot;
@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) AmazonAdInterstitial *interstitial;
@end
