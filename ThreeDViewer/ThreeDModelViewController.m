//
//  ThreeDModelViewController.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 9/26/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "ThreeDModelViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
@interface ThreeDModelViewController() {
    
    BOOL _isRotating;
    float _aspect;
    //Opengl缓存
    GLuint _vertexBuffer;
    Model *model;
    AVAudioPlayer *player;
}

@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) EAGLContext * context;
@property (strong, nonatomic) MBProgressHUD *HUD;
@end

@implementation ThreeDModelViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    [self.toolbar setHidden:YES];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"RGB"]) {
        bgR = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgR"];
        bgG = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgG"];
        bgB = [[NSUserDefaults standardUserDefaults] floatForKey:@"bgB"];
    } else {
        bgR = bgB = bgG = 255;
        [[NSUserDefaults standardUserDefaults] setFloat:bgR forKey:@"bgR"];
        [[NSUserDefaults standardUserDefaults] setFloat:bgG forKey:@"bgG"];
        [[NSUserDefaults standardUserDefaults] setFloat:bgB forKey:@"bgB"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RGB"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"LIGHT"]) {
        lightPos1.x = [[NSUserDefaults standardUserDefaults] floatForKey:@"light1.x"];
        lightPos1.y = [[NSUserDefaults standardUserDefaults] floatForKey:@"light1.y"];
        lightPos1.z = [[NSUserDefaults standardUserDefaults] floatForKey:@"light1.z"];
        
        lightPos2.x = [[NSUserDefaults standardUserDefaults] floatForKey:@"light2.x"];
        lightPos2.y = [[NSUserDefaults standardUserDefaults] floatForKey:@"light2.y"];
        lightPos2.z = [[NSUserDefaults standardUserDefaults] floatForKey:@"light2.z"];
        
        lightPos3.x = [[NSUserDefaults standardUserDefaults] floatForKey:@"light3.x"];
        lightPos3.y = [[NSUserDefaults standardUserDefaults] floatForKey:@"light3.y"];
        lightPos3.z = [[NSUserDefaults standardUserDefaults] floatForKey:@"light3.z"];
    } else {
        lightPos1.x = 0;
        lightPos1.y = 0;
        lightPos1.z = 1;
        
        lightPos2.x = 0;
        lightPos2.y = 0;
        lightPos2.z = -1;
        
        lightPos3.x = -1;
        lightPos3.y = 0;
        lightPos3.z = 0;
        [[NSUserDefaults standardUserDefaults] setFloat:lightPos1.x forKey:@"light1.x"];
        [[NSUserDefaults standardUserDefaults] setFloat:lightPos1.y forKey:@"light1.y"];
        [[NSUserDefaults standardUserDefaults] setFloat:lightPos1.z forKey:@"light1.z"];
        
        [[NSUserDefaults standardUserDefaults] setFloat:lightPos2.x forKey:@"light2.x"];
        [[NSUserDefaults standardUserDefaults] setFloat:lightPos2.y forKey:@"light2.y"];
        [[NSUserDefaults standardUserDefaults] setFloat:lightPos2.z forKey:@"light2.z"];
        
        [[NSUserDefaults standardUserDefaults] setFloat:lightPos3.x forKey:@"light3.x"];
        [[NSUserDefaults standardUserDefaults] setFloat:lightPos3.y forKey:@"light3.y"];
        [[NSUserDefaults standardUserDefaults] setFloat:lightPos3.z forKey:@"light3.z"];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LIGHT"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"flashlight" ofType:@"mp3"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];

    NSError *error = nil;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    [player prepareToPlay];

    self.title = [self.modelPath lastPathComponent];
    [self setupGL];

    [self resetTransform];
    
    model = [[Model alloc] initWithPath:self.modelPath
                               delegate:self];
    
    self.HUD = [[MBProgressHUD alloc] initWithView: self.view];
    self.HUD.label.text = @"Loading...";
    [self.view addSubview:self.HUD];
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.HUD showAnimated:TRUE];
    
    light1On = light2On = GL_TRUE;
    light3On = GL_FALSE;

    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    
    // 年月日をとりだす
    comps = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay)
                        fromDate:date];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    if(year >= 2016 && month >= 10 && day >= 22) {
        self.banner = [[IMBanner alloc] initWithFrame:CGRectMake(0, 0, 320, 50) placementId:1476251801709 delegate:self];
        [self.bannerContainer addSubview:self.banner];
        [self.banner load];
    }
}

-(IBAction)light1Touched:(id)sender {
    light1On = !light1On;
    [player play];
    if(!light1On) {
        [self.light1 setImage:[UIImage imageNamed:@"flashlight1_off.png"]];
    } else {
        [self.light1 setImage:[UIImage imageNamed:@"flashlight1_on.png"]];
    }
}
-(IBAction)light2Touched:(id)sender {
    light2On = !light2On;
    [player play];
    if(!light2On) {
        [self.light2 setImage:[UIImage imageNamed:@"flashlight2_off.png"]];
    } else {
        [self.light2 setImage:[UIImage imageNamed:@"flashlight2_on.png"]];
    }
}
-(IBAction)light3Touched:(id)sender {
    light3On = !light3On;
    [player play];
    if(!light3On) {
        [self.light3 setImage:[UIImage imageNamed:@"flashlight3_off.png"]];
    } else {
        [self.light3 setImage:[UIImage imageNamed:@"flashlight3_on.png"]];
    }
}
-(void) resetTransform {
    gesture = GESTURE_NONE;
    zoom = 1.0;
    lastZoom = 1.0;
    rotateY = rotateX = rotateZ = 0.0;
    lastRotateY = lastRotateX = lastRotateZ = 0.0;
}


-(void) dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if(_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
    }
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
    self.banner.delegate = nil;
}

-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self setupAspect];
    }];
}

//宽高比率调整
-(void) setupAspect {
    _aspect = (self.view.bounds.size.width) / (self.view.bounds.size.height);
}

- (void)setupGL {
    // OpenGL ES Settings
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    if (!context) {
//        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    }
    [EAGLContext setCurrentContext:self.context];
    
    GLKView* glkview = (GLKView *)self.view;
    glkview.context = self.context;
    
    if(_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
    }
    glGenBuffers(1, &_vertexBuffer);
    
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    self.effect = [[GLKBaseEffect alloc] init];
}

- (void)setMatrices {
    //光线设置
    self.effect.useConstantColor = GL_TRUE;
    self.effect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1);
    
    self.effect.transform.projectionMatrix = GLKMatrix4Identity;
    self.effect.transform.modelviewMatrix = GLKMatrix4Identity;
    
    self.effect.lightingType = GLKLightingTypePerPixel;
    self.effect.light0.enabled = light1On;
    self.effect.light0.position = GLKVector4Make(lightPos1.x, lightPos1.y, lightPos1.z, 0.0f);
    self.effect.light0.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.effect.light0.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    self.effect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
    
    self.effect.light1.enabled = light2On;
    self.effect.light1.position = GLKVector4Make(lightPos2.x, lightPos2.y, lightPos2.z, 0.0f);
    self.effect.light1.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.effect.light1.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    self.effect.light1.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
    
    //from left to right
    self.effect.light2.enabled = light3On;
    self.effect.light2.position = GLKVector4Make(lightPos3.x, lightPos3.y, lightPos3.z, 0.0f);
    self.effect.light2.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.effect.light2.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    self.effect.light2.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
    
    float scale = 2.0 / model.diameter;
    float near = 0.1;
    float far = 100.0;
    
    const GLfloat fieldView = GLKMathDegreesToRadians(60.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, _aspect, near, far);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // ModelView Matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, -model.zDiameter * scale - near - 1);
    if(gesture == GESTURE_ROTATEZ) {
        modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, -rotateZ);
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(rotateY));
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(rotateX));
    } else if(gesture == GESTURE_ROTATEX) {
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(rotateX));
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(rotateY));
        modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, -rotateZ);
    } else if(gesture == GESTURE_ROTATEY) {
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(rotateY));
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(rotateX));
        modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, -rotateZ);
    } else {
        modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, -rotateZ);
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(rotateY));
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(rotateX));
    }

    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, zoom, zoom, zoom);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scale, scale, scale);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, -model.center.x, -model.center.y, -model.center.z);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)update {
    if(model.ready) {
        [self setupAspect];
        [self setMatrices];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [EAGLContext setCurrentContext:self.context];
    glClearColor(bgR/255, bgG/255, bgB/255, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // Set matrices
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glCullFace(GL_BACK);
    if(model.ready) {
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(SceneVertex) * model.numOfTriangles * 3, model.pVertices, GL_STATIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, (GLsizei)sizeof(SceneVertex), 0);
        
        // Texels
        if(model.hasVertexCoord) {
            //NSLog(@"Enable texture coord");
            glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
            glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, (GLsizei)sizeof(SceneVertex), (GLvoid *)offsetof(SceneVertex, textcoord));
        }
        // Normals
        //if(model.hasNormal) {
            //NSLog(@"Enable normal");
            glEnableVertexAttribArray(GLKVertexAttribNormal);
            glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, (GLsizei)sizeof(SceneVertex), (GLvoid *)offsetof(SceneVertex, normal));
        //}
        
        GLsizei numOfVertexDrawed = 0;
        for (ModelGroup *mg in model.modelGroup) {
            for (MaterialGroup *materialGroup in mg.materialGroup) {
                if(materialGroup.numOfVertices > 0) {
                    [self.effect prepareToDraw];
                    NSString *materialName = materialGroup.name;
                    Material *material = [model.materialDict objectForKey:materialName];
                    if(!material) {
                        material = [Material defaultMaterial];
                    }
                    
                    self.effect.material.diffuseColor = material.diffuse;
                    self.effect.material.ambientColor = material.ambient;
                    self.effect.material.specularColor = material.spectral;
                    self.effect.material.shininess = material.shininess;
                    
                    if(model.hasVertexCoord && material.kdName) {
                        if(!material.mapKdTexture) {
                            NSError *error = nil;
                            material.mapKdTexture = [GLKTextureLoader textureWithContentsOfFile:material.kdName options:nil error:&error];
                        }
                        
                        if (material.mapKdTexture) {
                            self.effect.texture2d0.enabled = GL_TRUE;
                            self.effect.texture2d0.name = material.mapKdTexture.name;
                            self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
                        } else {
                            self.effect.texture2d0.enabled = GL_FALSE;
                        }
                    }
                    
                    glDrawArrays(GL_TRIANGLES, numOfVertexDrawed, (GLsizei)materialGroup.numOfVertices);
//
//                    glDrawArrays(GL_POINTS, numOfVertexDrawed, (GLsizei)materialGroup.numOfVertices);
                    numOfVertexDrawed += materialGroup.numOfVertices;
                }
            }
        }
    }
}

-(void) modelDidFinishedWithError:(NSError *) error {
    //NSLog(@"modelDidFinishedWithError:%@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!error) {
            [self.HUD.label setText:@"Loading finised, rendering..."];
            [self.HUD hideAnimated:YES afterDelay:1];
            [self.toolbar setHidden:NO];
        } else {
            [self.HUD.label setText:@"Error to load model"];
            [self.HUD hideAnimated:YES afterDelay:3];
        }
    });
}
-(void) modelDidProcessed:(NSString *) process {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.HUD.label setText:process];
//    });
}
-(void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //NSLog(@"didReceiveMemoryWarning");
    [self.HUD.label setText:@"Not enough memory"];
}


-(IBAction) pinchGesture:(UIPinchGestureRecognizer *) recognizer {
    if(gestureDisabled) {
        return;
    }
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        lastZoom = zoom;
    } else {
        zoom =  lastZoom - (1.0 - recognizer.scale);
    }
    zoom = MAX(zoom, 0.1);
//    zoom = MIN(zoom, 10);
    //NSLog(@"scale:%f, zoom:%f,lastZoom:%f",recognizer.scale, zoom,lastZoom);
}

-(IBAction) rotateGesture:(UIRotationGestureRecognizer *) recognizer {
    if(gestureDisabled) {
        return;
    }
    //NSLog(@"rotation:%f, velocity:%f",recognizer.rotation, recognizer.velocity);
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        lastRotateZ = rotateZ;
    } else {
        rotateZ =  lastRotateZ + recognizer.rotation;
    }
    gesture = GESTURE_ROTATEZ;
}
-(IBAction) panGesture:(UIPanGestureRecognizer *) recognizer {
    if(gestureDisabled) {
        return;
    }
    //NSLog(@"translation:%@",NSStringFromCGPoint([recognizer translationInView:self.view]));

    CGPoint translate = [recognizer translationInView:self.view];
   
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        lastRotateX = rotateX;
        lastRotateY = rotateY;
    } else {
        rotateX =  lastRotateX + translate.y;
        rotateY =  lastRotateY + translate.x;
    }
    if(fabs(translate.x) > fabs(translate.y)) {
        gesture =  GESTURE_ROTATEY;
    } else {
        gesture =  GESTURE_ROTATEX;
    }
}

-(IBAction)refreshTouched:(id)sender {
    [self resetTransform];
}

-(IBAction)snapshotTouched:(id)sender {
    GLKView* glkview = (GLKView *)self.view;
    if(model.ready) {
        snapshot = glkview.snapshot;
        [self performSegueWithIdentifier:@"snapshot" sender:self];
    }
}

-(IBAction)settingTouched:(id)sender {
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    settingViewController.delegate = self;
    gestureDisabled = YES;
    self.panGestureRecognizer.enabled = !gestureDisabled;
    self.rotationGestureRecognizer.enabled = !gestureDisabled;
    self.pinchGestureRecognizer.enabled = !gestureDisabled;
    
    [self addChildViewController:settingViewController];
    
    [settingViewController willMoveToParentViewController:self];
    [settingViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:settingViewController.view];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:settingViewController.view
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:settingViewController.view.superview
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    [settingViewController.view.superview addConstraint:widthConstraint];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:settingViewController.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:settingViewController.view.superview
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:0];
    [settingViewController.view.superview addConstraint:heightConstraint];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:settingViewController.view
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:settingViewController.view.superview
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1
                                                                          constant:0];
    [settingViewController.view.superview addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:settingViewController.view
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:settingViewController.view.superview
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:0];
    [settingViewController.view.superview addConstraint:centerYConstraint];
}

-(IBAction)inforTouched:(id)sender {
    ModelInfoViewController *infoViewController = [[ModelInfoViewController alloc] init];
    infoViewController.model = model;
    infoViewController.delegate = self;
    gestureDisabled = YES;
    [self addChildViewController:infoViewController];
    
    [infoViewController willMoveToParentViewController:self];
    [infoViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:infoViewController.view];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:infoViewController.view
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:infoViewController.view.superview
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    [infoViewController.view.superview addConstraint:widthConstraint];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:infoViewController.view
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:infoViewController.view.superview
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1
                                                                        constant:0];
    [infoViewController.view.superview addConstraint:heightConstraint];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:infoViewController.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:infoViewController.view.superview
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0];
    [infoViewController.view.superview addConstraint:centerXConstraint];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:infoViewController.view
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:infoViewController.view.superview
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:0];
    [infoViewController.view.superview addConstraint:centerYConstraint];
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"snapshot"]) {
        UINavigationController *nvc = segue.destinationViewController;
        SnapshotViewController *vc = nvc.viewControllers.firstObject;
        vc.snapshot = snapshot;
    }
}

#pragma mark -
/**
 * Notifies the delegate that the banner has finished loading
 */
-(void)bannerDidFinishLoading:(IMBanner*)banner {
    self.adTopConstrait.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
/**
 * Notifies the delegate that the banner has failed to load with some error.
 */
-(void)banner:(IMBanner*)banner didFailToLoadWithError:(IMRequestStatus*)error {
    self.adTopConstrait.constant = -50;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
/**
 * Notifies the delegate that the banner was interacted with.
 */
-(void)banner:(IMBanner*)banner didInteractWithParams:(NSDictionary*)params {
    
}
/**
 * Notifies the delegate that the user would be taken out of the application context.
 */
-(void)userWillLeaveApplicationFromBanner:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the banner would be presenting a full screen content.
 */
-(void)bannerWillPresentScreen:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the banner has finished presenting screen.
 */
-(void)bannerDidPresentScreen:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the banner will start dismissing the presented screen.
 */
-(void)bannerWillDismissScreen:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the banner has dismissed the presented screen.
 */
-(void)bannerDidDismissScreen:(IMBanner*)banner {
    
}
/**
 * Notifies the delegate that the user has completed the action to be incentivised with.
 */
-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    
}

#pragma mark -
-(void) infoDidFinished {
    [self settingDidFinished];
}
-(void) settingDidFinished {
    gestureDisabled = NO;
    self.panGestureRecognizer.enabled = !gestureDisabled;
    self.rotationGestureRecognizer.enabled = !gestureDisabled;
    self.pinchGestureRecognizer.enabled = !gestureDisabled;
}

-(void) backgroundColorDidChangedToR:(float) r g:(float) g b:(float) b {
    bgR = r;
    bgB = b;
    bgG = g;
    [[NSUserDefaults standardUserDefaults] setFloat:bgR forKey:@"bgR"];
    [[NSUserDefaults standardUserDefaults] setFloat:bgG forKey:@"bgG"];
    [[NSUserDefaults standardUserDefaults] setFloat:bgB forKey:@"bgB"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) light:(int) light positionChangedToX:(float) x y:(float) y z:(float)z {
    if(light == 1) {
        lightPos1.x = x;
        lightPos1.y = y;
        lightPos1.z = z;
    } else if(light == 2) {
        lightPos2.x = x;
        lightPos2.y = y;
        lightPos2.z = z;
    } else if(light == 3) {
        lightPos3.x = x;
        lightPos3.y = y;
        lightPos3.z = z;
    }
    
    [[NSUserDefaults standardUserDefaults] setFloat:lightPos1.x forKey:@"light1.x"];
    [[NSUserDefaults standardUserDefaults] setFloat:lightPos1.y forKey:@"light1.y"];
    [[NSUserDefaults standardUserDefaults] setFloat:lightPos1.z forKey:@"light1.z"];
    
    [[NSUserDefaults standardUserDefaults] setFloat:lightPos2.x forKey:@"light2.x"];
    [[NSUserDefaults standardUserDefaults] setFloat:lightPos2.y forKey:@"light2.y"];
    [[NSUserDefaults standardUserDefaults] setFloat:lightPos2.z forKey:@"light2.z"];
    
    [[NSUserDefaults standardUserDefaults] setFloat:lightPos3.x forKey:@"light3.x"];
    [[NSUserDefaults standardUserDefaults] setFloat:lightPos3.y forKey:@"light3.y"];
    [[NSUserDefaults standardUserDefaults] setFloat:lightPos3.z forKey:@"light3.z"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
