//
//  OneDriveUtil.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/8/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "OneDriveUtil.h"



//Mobile application:49dfc6b1-922e-40c3-90d1-3908c39c4e7f

static OneDriveUtil *oneDriveUtil;

@implementation OneDriveUtil

+(OneDriveUtil *) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        oneDriveUtil = [[OneDriveUtil alloc] init];
//         [ODClient setMicrosoftAccountAppId:APP_ID scopes:@[@"onedrive.readonly", @"offline_access"] ];
    });
    
    return oneDriveUtil;
}



@end
