//
//  SettingColorCell.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/10/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol SettingColorCellDelegate <NSObject>
//
//-(void) colorSettingDidFinished;
//@end
@class SettingViewController;

@interface SettingColorCell : UITableViewCell

@property(nonatomic, assign) SettingViewController *settingViewController;
@property(nonatomic, weak) IBOutlet UILabel *rLabel;
@property(nonatomic, weak) IBOutlet UILabel *gLabel;
@property(nonatomic, weak) IBOutlet UILabel *bLabel;

@property(nonatomic, weak) IBOutlet UISlider *rSlider;
@property(nonatomic, weak) IBOutlet UISlider *gSlider;
@property(nonatomic, weak) IBOutlet UISlider *bSlider;
@end
