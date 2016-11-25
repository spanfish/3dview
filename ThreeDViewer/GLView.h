//
//  GLView.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/2/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface GLView : UIView {
    EAGLContext *_context;
    GLuint _framebuffer;
    GLuint _renderbuffer;
    
    CADisplayLink *_displayLink;
    
    GLuint _vertexShader;
    GLuint _fragmentShader;
    GLuint _program;
    GLint _backingWidth;
    GLint _backingHeight;
}

@end
