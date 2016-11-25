//
//  SettingLightCell.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/10/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SettingViewController;

@interface SettingLightCell : UITableViewCell {

}

@property(nonatomic, weak) IBOutlet UILabel *xLabel;
@property(nonatomic, weak) IBOutlet UILabel *yLabel;
@property(nonatomic, weak) IBOutlet UILabel *zLabel;

@property(nonatomic, weak) IBOutlet UIStepper *xStepper;
@property(nonatomic, weak) IBOutlet UIStepper *yStepper;
@property(nonatomic, weak) IBOutlet UIStepper *zStepper;

@property(nonatomic, assign) int light;
@property(nonatomic, assign) SettingViewController *settingViewController;
@end
