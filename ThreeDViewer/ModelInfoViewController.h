//
//  ModelInfoViewController.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/9/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@protocol InfoViewDelegate <NSObject>
-(void) infoDidFinished;
@end

@interface ModelInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) Model *model;
@property(nonatomic, assign) id<InfoViewDelegate> delegate;
@end
