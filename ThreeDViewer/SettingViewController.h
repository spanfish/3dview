//
//  SettingViewController.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/10/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol SettingViewDelegate <NSObject>
-(void) settingDidFinished;
-(void) backgroundColorDidChangedToR:(float) r g:(float) g b:(float) b;
-(void) light:(int) light positionChangedToX:(float) x y:(float) y z:(float)z;
@end

@interface SettingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, weak) IBOutlet UIView *backgroundView;
@property(nonatomic, assign) id<SettingViewDelegate> delegate;
@end
