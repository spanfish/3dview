//
//  SettingViewController.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/10/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingLightCell.h"
#import "SettingColorCell.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingLightCell" bundle:nil]
         forCellReuseIdentifier:@"SettingLightCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingColorCell" bundle:nil]
         forCellReuseIdentifier:@"SettingColorCell"];

    CALayer *layer = self.backgroundView.layer;
    layer.cornerRadius = 8;
    layer.borderWidth = 1;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelTouched:(id)sender {
    if(self.delegate) {
        [self.delegate settingDidFinished];
    }
    [self.view removeFromSuperview];
}

#pragma mark -
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        SettingLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingLightCell" forIndexPath:indexPath];
        cell.settingViewController = self;
        cell.light = 1;
        
        return cell;
    } else if(indexPath.section == 1) {
        SettingLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingLightCell" forIndexPath:indexPath];
        cell.settingViewController = self;
        cell.light = 2;
        return cell;
    } else if(indexPath.section == 2) {
        SettingLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingLightCell" forIndexPath:indexPath];
        cell.settingViewController = self;
        cell.light = 3;
        return cell;
    } else if(indexPath.section == 3) {
        
        SettingColorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingColorCell" forIndexPath:indexPath];
        cell.settingViewController = self;
        return cell;
    }
    
    return nil;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 3) {
        return 125;
    }
    return 40;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Light1";
    } else if(section == 1) {
        return @"Light2";
    } else if(section == 2) {
        return @"Light3";
    } else if(section == 3) {
        return @"Background";
    }
    return nil;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}
@end
