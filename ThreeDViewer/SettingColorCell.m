//
//  SettingColorCell.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/10/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "SettingColorCell.h"
#import "SettingViewController.h"

@implementation SettingColorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.rSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgR"];
    self.gSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgG"];
    self.bSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgB"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)colorChanged:(id)sender {
    UISlider *slider = (UISlider *) sender;
    NSInteger tag = slider.tag;
    float r = self.rSlider.value;
    float g = self.gSlider.value;
    float b = self.bSlider.value;
    
    if(tag == 1) {
        self.rLabel.text = [NSString stringWithFormat:@"%.0f", slider.value];
    } else if(tag == 2) {
        self.gLabel.text = [NSString stringWithFormat:@"%.0f", slider.value];
    } else if(tag == 3) {
        self.bLabel.text = [NSString stringWithFormat:@"%.0f", slider.value];
    }
    [self.settingViewController.delegate backgroundColorDidChangedToR:r g:g b:b];
}
@end
