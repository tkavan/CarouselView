#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKit.h>

@protocol CarouselViewItem;

@interface MTACVDisplayStripe : NSObject

@property (nonatomic, assign, readonly) CGFloat angleSector;
@property (nonatomic, strong) id<CarouselViewItem> item;
@property (nonatomic, assign, readonly) CGFloat radius;
@property (nonatomic, assign) CGFloat glRaito;

@property (nonatomic, assign) GLuint positionSlot;
@property (nonatomic, assign) GLuint texCoordSlot;
@property (nonatomic, assign) GLuint colorUniform;
@property (nonatomic, assign) GLuint textureUniform;

-(id)initWithRadius:(CGFloat)aRadius glRaito:(CGFloat)aRaito;

-(void)draw;

@end
