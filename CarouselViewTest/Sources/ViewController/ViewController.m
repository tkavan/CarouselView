#import "ViewController.h"
#import "CarouselView.h"
#import "TouchManager.h"
#import "TouchManagerDelegate.h"

CGFloat ViewControllerZoomTreshold = 900.f;

#pragma mark - ViewController private interface

@interface ViewController ()<TouchManagerDelegate>

@property (nonatomic, strong) IBOutlet CarouselView* carouselView;
@property (nonatomic, strong) TouchManager* touchManager;
@property (nonatomic, strong) NSArray* items;

-(CGFloat)carouselAngleWithDistance:(CGFloat)aDistance;
-(CGFloat)carouselZoomWithVelocity:(CGFloat)aVelocity;

@end

#pragma mark ViewController implementation

@implementation ViewController
@synthesize carouselView, touchManager, items;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    CarouselView* cv = [[CarouselView alloc] initWithFrame:self.view.bounds radius:100.f];
    self.carouselView = cv;
    [self.view addSubview:self.carouselView];
    
    self.carouselView.radius = 1200.f;
    self.carouselView.zoom = 1.f;
    self.carouselView.itemMargin = 10.f;
    self.carouselView.backgroundColor = [UIColor lightGrayColor];
    
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:17];
    for (NSUInteger i = 0; i < 17   ; i++) {
        NSString* path = [NSString stringWithFormat:@"dior%02i.jpg", i];
        CarouselViewImageItem* imageItem = [[CarouselViewImageItem alloc] initWithPath:path];
        imageItem.backgroundColor = [UIColor blackColor];
        [arr addObject:imageItem];
    }
    self.items = [NSArray arrayWithArray:arr];
    self.carouselView.items = self.items;
    self.carouselView.angle = M_PI_4;
    
    self.touchManager = [TouchManager touchManagerWithDelegate:self view:self.carouselView];
    self.touchManager.flywheel = YES;
    self.touchManager.fraction = 0.88f;
    
    __unsafe_unretained ViewController* this = self;
    self.carouselView.tick = ^(CADisplayLink* aDl) {
        [this.touchManager tick:aDl];
    };
    
}

#pragma mark - ViewController private methods

-(CGFloat)carouselAngleWithDistance:(CGFloat)aDistance {
    return aDistance*0.002f;
}

-(CGFloat)carouselZoomWithVelocity:(CGFloat)aVelocity {
    aVelocity = ABS(aVelocity);
    aVelocity -= ViewControllerZoomTreshold;
    if (aVelocity < 0.f) {
        aVelocity = 0.f;
    }
    aVelocity *=0.0004f;
    if (aVelocity > 1.5f) {
        aVelocity = 1.5f;
    } else if (aVelocity < 0.f) {
        aVelocity = 0.f;
    }

    aVelocity = 1.f - aVelocity;
    return aVelocity;
}

#pragma mark - TouchManager delegate methods

-(void)touchManager:(TouchManager*)aManager didPan:(CGPoint)aDistance velocity:(CGPoint)aVelocity {
    self.carouselView.angle -= [self carouselAngleWithDistance:aDistance.x];
    self.carouselView.zoom = [self carouselZoomWithVelocity:aVelocity.x];
}

-(void)touchManager:(TouchManager*)aManager didOneTap:(CGPoint)aPosition {
    id<CarouselViewItem> item = [self.carouselView tapOnPoint:aPosition];
    if (item) {
        NSString* message = [NSString stringWithFormat:@"Item at index %i", [self.items indexOfObject:item]];
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Item tapped"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles:nil];
        [av show];
    }
}

@end
