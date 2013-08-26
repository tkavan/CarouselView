
#import <QuartzCore/QuartzCore.h>
#import "CarouselView.h"
#import "MTACVDisplayStripe.h"
#import "MTACVStripeStore.h"
#import "MTACVGLShader.h"
#import "MTACVGLProgram.h"

CGFloat CarouselViewNearPlane = 2.8f;
CGFloat CarouselViewFarPlane = 30.f;
CGFloat CarouselViewBaseRadius = 1000.f;
NSString* kCarouselViewErrorDomain = @"eu.mindtheapp.carouselview";

typedef struct {
    CGFloat min;
    CGFloat max;
} MTACVInterval;

#pragma mark CarouselView private interface

@interface CarouselView()<GLKViewDelegate>

@property (nonatomic, strong) GLKView* glView;
@property (nonatomic, strong) EAGLContext* glContext;
@property (nonatomic, strong) MTACVGLProgram* program;

@property (nonatomic, strong) CADisplayLink* dl;

@property (nonatomic, assign) GLuint positionSlot;
@property (nonatomic, assign) GLuint texCoordSlot;
@property (nonatomic, assign) GLuint projectionUniform;
@property (nonatomic, assign) GLuint modelViewUniform;
@property (nonatomic, assign) GLuint colorUniform;
@property (nonatomic, assign) GLuint textureUniform;
@property (nonatomic, assign) GLuint drawTypeUniform;

@property (nonatomic, strong) MTACVStripeStore* stripes;

-(void)initializeGL:(NSError**)aError;

-(void)refreshStripes;

-(MTACVInterval)displayedInterval;
-(MTACVInterval)preparedInterval;

-(void)render:(CADisplayLink*)aLink;

@end

#pragma mark - CarouselView implementation

@implementation CarouselView
@synthesize items;
@synthesize angle, totalAngle, zoom, cyclic, radius, backgroundColor;
@synthesize tick;
@synthesize glContext, glView, program;
@synthesize stripes;
@synthesize positionSlot, texCoordSlot, projectionUniform, modelViewUniform;
@synthesize colorUniform, textureUniform, drawTypeUniform;

#pragma mark - CarouselView init methods

-(id)initWithFrame:(CGRect)aFrame radius:(CGFloat)aRadius {
    if ((self = [super initWithFrame:aFrame])) {
        if (aRadius < self.frame.size.width) {
            aRadius = self.frame.size.width;
        }
        radius = aRadius;
        backgroundColor = [UIColor blackColor];
        NSError* err = nil;
        [self initializeGL:&err];
        if (err) {
            NSLog(@"Can't initialize carousel view (%@)", err);
            return nil;
        }
        [self refreshStripes];
    }
    return self;
}

-(id)initWithFrame:(CGRect)aFrame {
    return [self initWithFrame:aFrame radius:CarouselViewBaseRadius];
}

-(id)init {
    return [self initWithFrame:CGRectZero radius:CarouselViewBaseRadius];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    radius = CarouselViewBaseRadius;
    NSError* err = nil;
    [self initializeGL:&err];
    if (err) {
        NSException* exception = [NSException exceptionWithName:@"Carousel view failed load"
                                                        reason:[err.userInfo objectForKey:NSLocalizedDescriptionKey]
                                                      userInfo:nil];
        @throw exception;
    }
    [self refreshStripes];
}

#pragma mark - CarouselView public methods

-(id<CarouselViewItem>)tapOnPoint:(CGPoint)aPoint {
    id<CarouselViewItem> touchedItem = nil;
    for (MTACVDisplayStripe* stripe in self.stripes.displayed) {
        if ([self trySelectItem:stripe atPoint:aPoint]) {
            touchedItem = stripe.item;
            break;
        }
    }
    return touchedItem;
}

#pragma mark - CarouselView private methods

-(void)initializeGL:(NSError**)aError {
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.glContext) {
        *aError = [NSError errorWithDomain:kCarouselViewErrorDomain
                                      code:101
                                  userInfo:@{NSLocalizedDescriptionKey : @"Can't create gl context"}];
        return;
    }
    
    if (![EAGLContext setCurrentContext:self.glContext]) {
        *aError = [NSError errorWithDomain:kCarouselViewErrorDomain
                                      code:101
                                  userInfo:@{NSLocalizedDescriptionKey : @"Can't set gl context to current"}];
        return;
    }
    
    self.glView = [[GLKView alloc] initWithFrame:self.bounds context:self.glContext];
    self.glView.delegate = self;
    self.glView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [self addSubview:self.glView];
    self.glView.enableSetNeedsDisplay = YES;
    
    NSURL* bndUrl = [[NSBundle mainBundle] URLForResource:@"CarouselViewResources" withExtension:@"bundle"];
    NSBundle* bundle = [NSBundle bundleWithURL:bndUrl];
    MTACVGLShader* vertex = [[MTACVGLShader alloc] initWithContentOfURL:[bundle URLForResource:@"Vertex"
                                                                                 withExtension:@"glsl"]
                                                                   type:GL_VERTEX_SHADER];
    MTACVGLShader* fragment = [[MTACVGLShader alloc] initWithContentOfURL:[bundle URLForResource:@"Fragment"
                                                                                 withExtension:@"glsl"]
                                                                     type:GL_FRAGMENT_SHADER];
    self.program = [[MTACVGLProgram alloc] initWithVertexShader:vertex fragmentShader:fragment];
    [self.program compile];
    [self.program use];
    if (!self.program.compiled) {
        *aError = [NSError errorWithDomain:@"eu.mindtheapp.carouselview"
                                      code:103
                                  userInfo:@{NSLocalizedDescriptionKey : @"Can't compile program"}];
        return;
    }
    self.positionSlot = [self.program idForAttribute:@"Position"];
    self.texCoordSlot = [self.program idForAttribute:@"TexCoordIn"];
    self.projectionUniform = [self.program idForUniform:@"Projection"];
    self.modelViewUniform = [self.program idForUniform:@"Modelview"];
    self.colorUniform = [self.program idForUniform:@"SourceColor"];
    self.textureUniform = [self.program idForUniform:@"Texture"];
    self.drawTypeUniform = [self.program idForUniform:@"DisplayType"];
    
    glEnableVertexAttribArray(self.positionSlot);
    glEnableVertexAttribArray(self.texCoordSlot);
    
    self.dl = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [self.dl addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)invalidateAllStripes {
    self.stripes = nil;
}

-(void)refreshStripes {
    if (!self.stripes) {
        CGFloat ta = 0.f;
        NSMutableArray* marr = [NSMutableArray arrayWithCapacity:[self.items count]];
        for (id<CarouselViewItem> item in self.items) {
            MTACVDisplayStripe* stripe = [[MTACVDisplayStripe alloc] initWithRadius:self.radius
                                                                            glRaito:4.f/self.frame.size.width];
            stripe.positionSlot = self.positionSlot;
            stripe.texCoordSlot = self.texCoordSlot;
            stripe.colorUniform = self.colorUniform;
            stripe.textureUniform = self.textureUniform;
            stripe.drawTypeUniform = self.drawTypeUniform;

            stripe.item = item;
            [marr addObject:stripe];
            
            ta += stripe.angleSector;
        }
        self.stripes = [[MTACVStripeStore alloc] initWithStripes:marr carouselView:self];
        totalAngle = ta;
    }

    MTACVInterval displayedInt = [self displayedInterval];
    MTACVInterval preparedInt = [self preparedInterval];
    
    CGFloat beginAngle = 0.f;
    for (MTACVDisplayStripe* item in self.stripes.stripes) {
        CGFloat endAngle = beginAngle + item.angleSector;
        if ((beginAngle >= displayedInt.min && beginAngle <= displayedInt.max) ||
            (endAngle >= displayedInt.min && endAngle <= displayedInt.max)) {
            [self.stripes displayStripe:item];
        } else if ((beginAngle >= preparedInt.min && beginAngle <= preparedInt.max) ||
                   (endAngle >= preparedInt.min && endAngle <= preparedInt.max)) {
            [self.stripes hideStripe:item];
            [self.stripes prepareStripe:item];
        } else {
            [self.stripes freeStripe:item];
        }
        
        beginAngle = endAngle;
    }
    
    [self.glView setNeedsDisplay];
}

-(MTACVInterval)displayedInterval {
    float intervalAngle = tan(2.f/CarouselViewNearPlane);
    return (MTACVInterval){self.angle - intervalAngle, self.angle + intervalAngle};
}


-(MTACVInterval)preparedInterval {
    float safety = M_PI_4;
    MTACVInterval interval = [self displayedInterval];
    interval.min -= safety;
    interval.max += safety;
    return interval;
}

-(void)render:(CADisplayLink*)aLink {
    if (self.tick) {
        self.tick(aLink);
    }
    [self.glView setNeedsDisplay];
}

-(BOOL)trySelectItem:(MTACVDisplayStripe*)aStripe atPoint:(CGPoint)aPoint {
    GLKVector4 vec = GLKVector4Make(0.f, 0.f, 0.f, 0.f);
    [self.backgroundColor getRed:&vec.r green:&vec.g blue:&vec.b alpha:&vec.a];
    glClearColor(vec.r, vec.g, vec.b, vec.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    glViewport(0, 0, self.glView.frame.size.width, self.glView.frame.size.height);
    
    float h = 4.0f * self.glView.frame.size.height / self.glView.frame.size.width;
    GLKMatrix4 projection = GLKMatrix4MakeFrustum(-2.f, 2.f, -h/2.f, h/2.f, CarouselViewNearPlane, CarouselViewFarPlane);
    glUniformMatrix4fv(self.projectionUniform, 1, 0, (GLfloat*)(&projection));
    
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0.f, 0.f, self.zoom*1.5f-0.5f);
    modelView = GLKMatrix4Rotate(modelView, self.angle, 0.f, 1.f, 0.f);
    for (MTACVDisplayStripe* stripe in self.stripes.stripes) {
        if (stripe == aStripe) {
            glUniformMatrix4fv(self.modelViewUniform, 1, 0, (GLfloat*)(&modelView));
            [stripe draw:MTACVDisplayStripeDrawSelect];
            break;
        }
        modelView = GLKMatrix4Rotate(modelView, -stripe.angleSector, 0.f, 1.f, 0.f);
    }
    
    Byte pixelColor[4] = {0,};
    CGFloat scale = UIScreen.mainScreen.scale;
    glReadPixels( aPoint.x * scale
                , self.glView.drawableHeight - (aPoint.y * scale)
                , 1
                , 1
                , GL_RGBA, GL_UNSIGNED_BYTE
                , pixelColor);
    
    return pixelColor[0] != 0;
}

#pragma mark - CarouselView accessor methods

-(void)setAngle:(CGFloat)aAngle {
    while (aAngle < 0.f) {
        aAngle = 0.f;
        //aAngle = M_PI*2+aAngle;
    }
    if (aAngle > self.totalAngle) {
        aAngle = self.totalAngle;
    }
    
    angle = aAngle;
    [self refreshStripes];
}

-(void)setRadius:(CGFloat)aRadius {
    if (aRadius < self.frame.size.width) {
        aRadius = self.frame.size.width;
    }
    
    if (aRadius*(4.f/self.frame.size.width) > CarouselViewFarPlane) {
        aRadius = CarouselViewBaseRadius / (4.f/self.frame.size.width);
    }

    if (radius == aRadius) {
        return;
    }

    radius = aRadius;
    [self invalidateAllStripes];
    [self refreshStripes];
}

-(void)setItems:(NSArray*)aItems {
    if (aItems == items) {
        return;
    }
    items = aItems;
    [self invalidateAllStripes];
    self.angle = 0.f;
}

-(void)setBackgroundColor:(UIColor*)aBackgroundColor {
    if (aBackgroundColor == backgroundColor) {
        return;
    }
    backgroundColor = aBackgroundColor;
    [self.glView setNeedsDisplay];
}

#pragma mark - GLKView delegate methods

-(void)glkView:(GLKView*)aView drawInRect:(CGRect)aRect {
    GLKVector4 vec = GLKVector4Make(0.9f, 0.9f, 0.9f, 1.f);
    [self.backgroundColor getRed:&vec.r green:&vec.g blue:&vec.b alpha:&vec.a];
    glClearColor(vec.r, vec.g, vec.b, vec.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    glViewport(0, 0, self.glView.frame.size.width, self.glView.frame.size.height);
    
    float h = 4.0f * self.glView.frame.size.height / self.glView.frame.size.width;
    GLKMatrix4 projection = GLKMatrix4MakeFrustum(-2.f, 2.f, -h/2.f, h/2.f, CarouselViewNearPlane, CarouselViewFarPlane);
    glUniformMatrix4fv(self.projectionUniform, 1, 0, (GLfloat*)(&projection));
    
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0.f, 0.f, self.zoom*1.5f-0.5f);
    modelView = GLKMatrix4Rotate(modelView, self.angle, 0.f, 1.f, 0.f);
    for (MTACVDisplayStripe* stripe in self.stripes.stripes) {
        if ([self.stripes isStripeDisplayed:stripe]) {
            glUniformMatrix4fv(self.modelViewUniform, 1, 0, (GLfloat*)(&modelView));
            [stripe draw:MTACVDisplayStripeDrawDisplay];
        }
        modelView = GLKMatrix4Rotate(modelView, -stripe.angleSector, 0.f, 1.f, 0.f);
    }
}

@end
