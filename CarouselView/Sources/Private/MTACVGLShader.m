#import "MTACVGLShader.h"

const NSInteger kCTTFlowShaderMaxLength = 2048;

#pragma mark MTACVGLShader private interface

@interface MTACVGLShader()

@property (nonatomic, readwrite, assign) GLuint sid;
@property (nonatomic, readwrite, assign) GLenum type;
@property (nonatomic, readwrite, copy) NSString* string;

@end

#pragma mark - MTACVGLShader implementation

@implementation MTACVGLShader
@synthesize sid, type, loaded, string;

#pragma mark - MTACVGLShader init methods

-(id)initWithString:(NSString*)aString type:(GLenum)aType {
    if ((self = [super init])) {
        string = aString;
        type = aType;
        loaded = NO;
    }
    return self;
}

-(id)initWithContentOfURL:(NSURL*)aURL type:(GLenum)aType {
    NSString* str = [NSString stringWithContentsOfURL:aURL encoding:NSUTF8StringEncoding error:nil];
    return [self initWithString:str type:aType];
}

-(id)init {
    return [self initWithString:nil type:GL_VERTEX_SHADER];
}

-(void)dealloc {
    if (self.sid) {
        glDeleteShader(self.sid);
    }
}

#pragma mark - MTACVGLShader public methods

-(void)load {
    self.sid = glCreateShader(type);
    if (!self.sid) {
        NSLog(@"Cannot create shader.");
        return;
    }
    
    NSInteger length = [self.string length]+1;
    char* shaderStr = malloc(length*sizeof(char));
    if (!shaderStr) {
        NSLog(@"Shader c-string: Memory malloc error.");
        return;
    }

    [self.string getCString:shaderStr maxLength:length encoding:NSASCIIStringEncoding];
    glShaderSource(self.sid, 1, (const char**)&shaderStr, &length);
    glCompileShader(self.sid);
    free(shaderStr);
    
    GLint compiled;
    glGetShaderiv(self.sid, GL_COMPILE_STATUS, &compiled);
    
    if (!compiled) {
        GLint logLength = 0;
        glGetShaderiv(self.sid, GL_INFO_LOG_LENGTH, &logLength);
        NSString* info = @"";
        if (logLength > 1) {
            shaderStr = malloc(logLength * sizeof(GLchar));
            if (!shaderStr) {
                NSLog(@"Shader c-string: Memory malloc error.");
                return;
            }
            glGetShaderInfoLog(self.sid, logLength, 0x0, shaderStr);
            info = [NSString stringWithCString:shaderStr encoding:NSUTF8StringEncoding];
            free(shaderStr);
        }
        NSLog(@"Cannot compile shader: %@", info);
        return;
    }
    loaded = YES;
}

@end
