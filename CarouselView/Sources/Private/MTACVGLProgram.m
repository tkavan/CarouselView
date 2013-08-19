#import "MTACVGLProgram.h"
#import "MTACVGLShader.h"

#pragma mark MTACVGLProgram private interface

@interface MTACVGLProgram()

@property (nonatomic, assign, readwrite) GLuint pid;
@property (nonatomic, assign, readwrite, getter = isCompiled) BOOL compiled;

@end

#pragma mark - MTACVGLProgram implementation

@implementation MTACVGLProgram
@synthesize pid, compiled;
@synthesize fragmentShader, vertexShader;

#pragma mark - MTACVGLProgram init methods

-(id)initWithVertexShader:(MTACVGLShader*)aVertex fragmentShader:(MTACVGLShader*)aFragment {
    if ((self = [super init])) {
        fragmentShader = aFragment;
        vertexShader = aVertex;
        compiled = NO;
    }
    return self;
}

-(id)init {
    return [self initWithVertexShader:nil fragmentShader:nil];
}

-(void)dealloc {
    if (pid) {
        glDeleteProgram(pid);
    }
}

#pragma mark - MTACVGLProgram public methods

-(void)compile {
    if (!self.fragmentShader || !self.vertexShader) {
        NSLog(@"Program must be compiled with both shaders");
        return;
    }
    if (!self.fragmentShader.loaded) {
        [self.fragmentShader load];
    }
    if (!self.vertexShader.loaded) {
        [self.vertexShader load];
    }
    
    self.pid = glCreateProgram();
    if (!self.pid) {
        NSLog(@"Cannot create program.");
    }

    glAttachShader(self.pid, self.vertexShader.sid);
    glAttachShader(self.pid, self.fragmentShader.sid);
    
    glLinkProgram(self.pid);
    
    GLint linked;
    glGetProgramiv(self.pid, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint logLength = 0;
        glGetProgramiv(self.pid, GL_INFO_LOG_LENGTH, &logLength);
        NSString* log = @"";
        if (logLength > 1) {
            char* logStr = malloc(logLength*sizeof(char));
            if (!logStr) {
                 NSLog(@"Program c-string: Memory malloc error.");
                return;
            }
            glGetProgramInfoLog(self.pid, logLength, 0x0, logStr);
            log = [NSString stringWithCString:logStr encoding:NSUTF8StringEncoding];
            free(logStr);
        }
        NSLog(@"Program compilation with error: %@", log);
        return;
    }
    NSLog(@"Flow Program: sucessfully compiled and linked.");
    self.compiled = YES;
}

-(void)use {
    if (!self.compiled) {
        NSLog(@"Program cannot be set before compilation.");
        return;
    }
    glUseProgram(self.pid);
}

-(GLint)idForUniform:(NSString*)aString {
    GLint uniform = 0;
    NSInteger lengt = [aString length]+1;
    GLchar* uniformStr = malloc(lengt*sizeof(GLchar));
    if (!uniformStr) {
        NSLog(@"Program c-string: Memory malloc error.");
    } else {
        [aString getCString:uniformStr maxLength:lengt encoding:NSASCIIStringEncoding];
        uniform = glGetUniformLocation(self.pid, uniformStr);
        free(uniformStr);
    }
    return uniform;
}

-(GLint)idForAttribute:(NSString*)aString {
    GLint attribute = 0;
    NSInteger lengt = [aString length]+1;
    GLchar* attributeStr = malloc(lengt*sizeof(GLchar));
    if (!attributeStr) {
        NSLog(@"Program c-string: Memory malloc error.");
    } else {
        [aString getCString:attributeStr maxLength:lengt encoding:NSASCIIStringEncoding];
        attribute = glGetAttribLocation(self.pid, attributeStr);
        free(attributeStr);
    }
    return attribute;
}

@end
