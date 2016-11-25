//
//  GLView.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/2/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "GLView.h"
#import <GLKit/GLKit.h>

const float cubeNormals[108] =
{
    1, 0, 0,
    1, 0, 0,
    1, 0, 0,
    1, 0, 0,
    1, 0, 0,
    1, 0, 0,
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,
    -0, -0, 1,
    -0, -0, 1,
    -0, -0, 1,
    -0, -0, 1,
    -0, -0, 1,
    -0, -0, 1,
    0, -1, 0,
    0, -1, 0,
    0, -1, 0,
    0, -1, 0,
    0, -1, 0,
    0, -1, 0,
    -1, -0, -0,
    -1, -0, -0,
    -1, -0, -0,
    -1, -0, -0, 
    -1, -0, -0, 
    -1, -0, -0, 
    0, 1, 0, 
    0, 1, 0, 
    0, 1, 0, 
    0, 1, 0, 
    0, 1, 0, 
    0, 1, 0, 
};

@implementation GLView

+(Class) layerClass {
    return [CAEAGLLayer class];
}

- (id)init {
    self = [super init];
    if(self) {
        [self setupGLView];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if(self) {
        [self setupGLView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder: coder];
    if(self) {
        [self setupGLView];
    }
    return self;

}

-(void) layoutSubviews {
    [super layoutSubviews];
    NSLog(@"rect:%@", NSStringFromCGRect(self.frame));
}

-(void) setupGLView {
    float scale = [UIScreen mainScreen].scale;
    CAEAGLLayer *layer =  (CAEAGLLayer*) self.layer;
    [layer setContentsScale:scale];
    layer.opaque = YES;
    layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:NO],
                                kEAGLDrawablePropertyRetainedBacking,
                                kEAGLColorFormatRGBA8,
                                kEAGLDrawablePropertyColorFormat,
                                nil];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if(!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if(!_context) {
        NSAssert(NO, @"OpenGLES 2 not supported");
    }
    
    [EAGLContext setCurrentContext:_context];
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glGenRenderbuffers(1,  &_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    _vertexShader = [self loadShader:@"vertex" ofType:GL_VERTEX_SHADER];
    _fragmentShader = [self loadShader:@"fragment" ofType:GL_FRAGMENT_SHADER];
    
    _program = glCreateProgram();
    if(_program == 0) {
        return;
    }
    glAttachShader(_program, _vertexShader);
    glAttachShader(_program, _fragmentShader);
    glBindAttribLocation(_program, 0, "a_position");
    glLinkProgram(_program);
    GLint linked = 0;
    glGetProgramiv(_program, GL_LINK_STATUS, &linked);
    if(!linked) {
        GLint infoLen = 0;
        glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &infoLen);
        if(infoLen > 0) {
            char* infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(_program, infoLen, NULL, infoLog);
            NSLog(@"compile error:%s", infoLog);
            free(infoLog);
        }
        
        glDeleteShader(_program);
    }
//    glDeleteShader(_vertexShader);
//    glDeleteShader(_fragmentShader);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
    
    GLint result = 0;
    glGetProgramiv(_program, GL_ACTIVE_UNIFORMS, &result);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

-(GLuint) loadShader:(NSString *) file ofType:(GLenum) type {
    GLuint shader;
    GLint compiled;
    
    shader = glCreateShader(type);
    if(!shader) {
        return 0;
    }

    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"sh"];
    NSString *sourceString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (sourceString == nil) {
        return 0;
    }
    
    const GLchar *source;
    source = (GLchar *)[sourceString UTF8String];
    
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if(!compiled) {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if(infoLen > 0) {
            char* infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            NSLog(@"compile error:%s", infoLog);
            free(infoLog);
        }
        
        glDeleteShader(shader);
    }
    return shader;
}

-(void) update:(CADisplayLink *) displayLink {
    //NSLog(@"update");
    [self render];
}

-(void) render {
    [EAGLContext setCurrentContext:_context];
    glClearColor(0.8f, 0.8f, 0.8f, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    //glEnable(GL_DEPTH_TEST);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);

    glViewport((_backingWidth - self.bounds.size.width) / 2,
               (_backingHeight - self.bounds.size.height) / 2,
               self.bounds.size.width,
               self.bounds.size.height);
    
    const float cubePositions[108] =
    {
        1, -1, -1,
        1, 1, -0.999999,
        0.999999, 1, 1,
        1, -1, -1,
        0.999999, 1, 1,
        1, -1, 1,
        1, 1, -0.999999,
        1, -1, -1,
        -1, -1, -1,
        1, 1, -0.999999,
        -1, -1, -1,
        -1, 1, -1,
        1, -1, 1,
        0.999999, 1, 1,
        -1, 1, 1,
        1, -1, 1,
        -1, 1, 1,
        -1, -1, 1,
        1, -1, -1,
        1, -1, 1,
        -1, -1, 1,
        1, -1, -1,
        -1, -1, 1,
        -1, -1, -1, 
        -1, -1, 1, 
        -1, 1, 1, 
        -1, 1, -1, 
        -1, -1, 1, 
        -1, 1, -1, 
        -1, -1, -1, 
        1, 1, -0.999999, 
        -1, 1, -1, 
        -1, 1, 1, 
        1, 1, -0.999999, 
        -1, 1, 1, 
        0.999999, 1, 1, 
    };
    glUseProgram(_program);
    
    float aspect = CGRectGetWidth(self.frame) / CGRectGetHeight(self.frame);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, .01f, 100.0f);
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(0, 0, 1, 0, 0, 0, 0, 1, 0);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    //modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(0));
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, -5.0f);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(0));
    
    GLuint p = glGetUniformLocation(_program, "Projection");
    GLuint v = glGetUniformLocation(_program, "View");
    GLuint m = glGetUniformLocation(_program, "Model");
    
    glUniformMatrix4fv(p, 1, GL_FALSE, projectionMatrix.m);
    glUniformMatrix4fv(v, 1, GL_FALSE, viewMatrix.m);
    glUniformMatrix4fv(m, 1, GL_FALSE, modelViewMatrix.m);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, cubePositions);
    glEnableVertexAttribArray(0);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
@end
