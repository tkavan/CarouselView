#import <QuartzCore/QuartzCore.h>
#import "TouchManager.h"
#import "TouchManagerDelegate.h"

CGFloat TouchManagerBaseFps = 60.f;
CGFloat TouchManagerBaseFraction = 0.88f;
CGFloat TouchManagerFlywheelLowTreshold = 0.0001f;

#pragma mark TouchManager private interface

@interface TouchManager()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer* panGesture;
@property (nonatomic, strong) UITapGestureRecognizer* oneTapGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer* pinchGesture;

@property (nonatomic, assign) CGPoint lastPanPosition;

@property (nonatomic, assign) CGPoint flywheelSpeed;
@property (nonatomic, assign, getter = isFlywheelPaused) BOOL flywheelPaused;

-(void)panGestureDetected:(UIPanGestureRecognizer*)aPanGesture;
-(void)oneTapGestureDetected:(UITapGestureRecognizer*)aTapGesture;
-(void)pinchGestureDetected:(UIPinchGestureRecognizer*)aPinchGesture;

@end

#pragma mark - TouchManager implementation

@implementation TouchManager
@synthesize delegate, view;
@synthesize fraction;
@synthesize panGesture, oneTapGesture, pinchGesture;
@synthesize lastPanPosition;
@synthesize flywheelSpeed, flywheelPaused;

#pragma mark - TouchManager init methods

-(id)initWithDelegate:(id<TouchManagerDelegate>)aDelegate {
    return [self initWithDelegate:aDelegate view:nil];
}

+(TouchManager*)touchManagerWithDelegate:(id<TouchManagerDelegate>)aDelegate {
    return [[TouchManager alloc] initWithDelegate:aDelegate];
}

-(id)initWithDelegate:(id<TouchManagerDelegate>)aDelegate view:(UIView*)aView {
    if ((self = [super init])) {
        delegate = aDelegate;
        
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
        oneTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapGestureDetected:)];
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureDetected:)];
        panGesture.delegate = self;
        oneTapGesture.delegate = self;
        pinchGesture.delegate = self;
        
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 2;
        oneTapGesture.numberOfTouchesRequired = 1;
        oneTapGesture.numberOfTapsRequired = 1;
        
        // TODO configure pinch gesture
        
        fraction = TouchManagerBaseFraction;
        flywheelPaused = YES;
        
        [self setView:aView];
    }
    return self;
}

+(TouchManager*)touchManagerWithDelegate:(id<TouchManagerDelegate>)aDelegate view:(UIView*)aView {
    return [[TouchManager alloc] initWithDelegate:aDelegate view:aView];
}

#pragma mark - TouchManager public methods

-(void)tick:(CADisplayLink*)aDl {
    if (self.flywheel && !self.flywheelPaused) {
        NSTimeInterval duration = 1.f/(TouchManagerBaseFps);
        CGPoint translation = CGPointMake(self.flywheelSpeed.x*duration, self.flywheelSpeed.y*duration);
        self.flywheelSpeed = CGPointMake(self.flywheelSpeed.x*self.fraction, self.flywheelSpeed.y*self.fraction);
        if ([self.delegate respondsToSelector:@selector(touchManager:didPan:velocity:)]) {
            [self.delegate touchManager:self didPan:translation velocity:self.flywheelSpeed];
        }
        if (ABS(self.flywheelSpeed.x) < TouchManagerFlywheelLowTreshold) {
            self.flywheelSpeed = CGPointMake(0.f, self.flywheelSpeed.y);
        }
        if (ABS(self.flywheelSpeed.y) < TouchManagerFlywheelLowTreshold) {
            self.flywheelSpeed = CGPointMake(self.flywheelSpeed.x, 0.f);
        }
        
        if (self.flywheelSpeed.x == 0.f && self.flywheelSpeed.y == 0.f) {
            self.flywheelPaused = YES;
        }
    } else {
        self.flywheelSpeed = CGPointZero;
        self.flywheelPaused = YES;
    }
}

#pragma mark - TouchManager accessor methods

-(void)setView:(UIView*)aView {
    if (view == aView) {
        return;
    }
    
    [view removeGestureRecognizer:self.panGesture];
    [view removeGestureRecognizer:self.oneTapGesture];
    [view removeGestureRecognizer:pinchGesture];
    [aView addGestureRecognizer:self.panGesture];
    [aView addGestureRecognizer:self.oneTapGesture];
    [aView addGestureRecognizer:self.pinchGesture];
    
    view = aView;
}

#pragma mark - TouchManager private methods

-(void)panGestureDetected:(UIPanGestureRecognizer*)aPanGesture {
    CGPoint ret;
    CGPoint pnt;
    switch (aPanGesture.state) {
        case UIGestureRecognizerStateEnded:
            if (self.flywheel) {
                self.flywheelPaused = NO;
                self.flywheelSpeed = [aPanGesture velocityInView:self.view];
            }
            break;
        case UIGestureRecognizerStateBegan:
            self.flywheelSpeed = CGPointZero;
            self.flywheelPaused = YES;
            self.lastPanPosition = CGPointZero;
            break;
        case UIGestureRecognizerStateChanged:
            pnt = [self.panGesture translationInView:self.view];
            ret = CGPointMake(pnt.x-self.lastPanPosition.x, pnt.y-self.lastPanPosition.y);
            self.lastPanPosition = pnt;
            if ([self.delegate respondsToSelector:@selector(touchManager:didPan:velocity:)]) {
                [self.delegate touchManager:self didPan:ret velocity:[self.panGesture velocityInView:self.view]];
            }
            break;
        default:
            break;
    }
}

-(void)oneTapGestureDetected:(UITapGestureRecognizer*)aTapGesture {
    if ([self.delegate respondsToSelector:@selector(touchManager:didOneTap:)]) {
        [self.delegate touchManager:self didOneTap:[aTapGesture locationInView:self.view]];
    }
}

-(void)pinchGestureDetected:(UIPinchGestureRecognizer*)aPinchGesture {
    // TODO
}

@end
