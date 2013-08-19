#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class MTACVGLShader;

@interface MTACVGLProgram : NSObject

@property (nonatomic, assign, readonly) GLuint pid;
@property (nonatomic, strong) MTACVGLShader* vertexShader;
@property (nonatomic, strong) MTACVGLShader* fragmentShader;
@property (nonatomic, assign, readonly, getter = isCompiled) BOOL compiled;

-(id)initWithVertexShader:(MTACVGLShader*)aVertex fragmentShader:(MTACVGLShader*)aFragment;

-(void)compile;
-(void)use;

-(GLint)idForUniform:(NSString*)aString;
-(GLint)idForAttribute:(NSString*)aString;

@end
