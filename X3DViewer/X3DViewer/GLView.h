//
//  GLView.h
//  X3DViewer
//
//  Created by xiangwei wang on 10/11/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface GLView : NSOpenGLView {
    CVDisplayLinkRef displayLink;
}

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime;
@end
