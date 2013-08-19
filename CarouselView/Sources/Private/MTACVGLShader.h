#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface MTACVGLShader : NSObject

@property (nonatomic, readonly) GLuint sid;
@property (nonatomic, readonly) GLenum type;
@property (nonatomic, readonly, copy) NSString* string;
@property (nonatomic, readonly, getter = isLoaded) BOOL loaded;

-(id)initWithString:(NSString*)aString type:(GLenum)aType;
-(id)initWithContentOfURL:(NSURL*)aURL type:(GLenum)aType;

-(void)load;

@end
