//
//  SettingLightCell.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/10/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "SettingLightCell.h"
#import "SettingViewController.h"

@implementation SettingLightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}
-(void) setLight:(int)light {
    _light = light;
    float x = [[NSUserDefaults standardUserDefaults] floatForKey:[NSString stringWithFormat:@"light%d.x", _light]];
    float y = [[NSUserDefaults standardUserDefaults] floatForKey:[NSString stringWithFormat:@"light%d.y", _light]];
    float z = [[NSUserDefaults standardUserDefaults] floatForKey:[NSString stringWithFormat:@"light%d.z", _light]];
    
    self.xStepper.value = x;
    self.yStepper.value = y;
    self.zStepper.value = z;
    
    self.xLabel.text = [NSString stringWithFormat:@"x:%.0f", self.xStepper.value];
    self.yLabel.text = [NSString stringWithFormat:@"y:%.0f", self.yStepper.value];
    self.zLabel.text = [NSString stringWithFormat:@"z:%.0f", self.zStepper.value];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)positionChanged:(id)sender {
    UIStepper *stepper = sender;
    if(stepper.tag == 1) {
        self.xLabel.text = [NSString stringWithFormat:@"x:%.0f", stepper.value];
    } else if(stepper.tag == 2) {
        self.yLabel.text = [NSString stringWithFormat:@"y:%.0f", stepper.value];
    } else if(stepper.tag == 3) {
        self.zLabel.text = [NSString stringWithFormat:@"z:%.0f", stepper.value];
    }
    float x = self.xStepper.value;
    float y = self.yStepper.value;
    float z = self.zStepper.value;
    
    [self.settingViewController.delegate light:_light positionChangedToX:x y:y z:z];
}
@end
