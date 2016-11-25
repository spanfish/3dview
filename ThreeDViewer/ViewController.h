//
//  ViewController.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 9/26/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <InMobiSDK/InMobiSDK.h>

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, IMBannerDelegate>

@property(nonatomic, strong) IMBanner *banner;
@property(nonatomic, strong) IBOutlet UIView *bannerContainer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *adTopConstrait;
-(IBAction)loadFiles:(id)sender;
@end

