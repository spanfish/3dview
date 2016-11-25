//
//  ThreeDModelViewController.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 9/26/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Model.h"
#import <InMobiSDK/InMobiSDK.h>
#import "ModelInfoViewController.h"
#import "SettingViewController.h"
#import "MBProgressHUD.h"
#import "Model.h"
#import "SnapshotViewController.h"

typedef enum {
    GESTURE_NONE,
    GESTURE_ROTATEX,
    GESTURE_ROTATEY,
    GESTURE_ROTATEZ
} Gesture;

@interface ThreeDModelViewController : GLKViewController<ModelDelegate, IMBannerDelegate, SettingViewDelegate, InfoViewDelegate> {
    Gesture gesture;
    CGFloat zoom;
    CGFloat lastZoom;
    
    CGFloat rotateY;
    CGFloat lastRotateY;
    CGFloat rotateX;
    CGFloat lastRotateX;
    
    CGFloat lastRotateZ;
    CGFloat rotateZ;
    UIImage *snapshot;
    
    int light1On;
    int light2On;
    int light3On;
    
    BOOL gestureDisabled;
    float bgR;
    float bgG;
    float bgB;
    
    GLKVector3 lightPos1;
    GLKVector3 lightPos2;
    GLKVector3 lightPos3;
}


@property(nonatomic, strong) NSString *modelPath;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *light1;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *light2;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *light3;
@property(nonatomic, strong) IMBanner *banner;
@property(nonatomic, weak) IBOutlet UIView *bannerContainer;
@property(nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adTopConstrait;

@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIRotationGestureRecognizer *rotationGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGestureRecognizer;
@end
