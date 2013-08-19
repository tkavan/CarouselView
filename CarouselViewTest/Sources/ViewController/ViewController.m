#import "ViewController.h"
#import "CarouselView.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet CarouselView* carouselView;
@property (nonatomic, strong) UIPanGestureRecognizer* gestureRecognizer;

@end

@implementation ViewController
@synthesize carouselView, gestureRecognizer;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    CarouselView* cv = [[CarouselView alloc] initWithFrame:self.view.bounds radius:100.f];
    self.carouselView = cv;
    [self.view addSubview:self.carouselView];
    
    self.carouselView.radius = 1200.f;
    self.carouselView.zoom = 0.5f;
    self.carouselView.itemMargin = 10.f;
    self.carouselView.backgroundColor = [UIColor lightGrayColor];
    
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:17];
    for (NSUInteger i = 0; i < 17   ; i++) {
        NSString* path = [NSString stringWithFormat:@"dior%02i.jpg", i];
        CarouselViewImageItem* imageItem = [[CarouselViewImageItem alloc] initWithPath:path];
        imageItem.backgroundColor = [UIColor blackColor];
        [arr addObject:imageItem];
    }
    self.carouselView.items = arr;
    
    self.carouselView.angle = M_PI_4;
    
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.carouselView addGestureRecognizer:self.gestureRecognizer];
}

// Temporary method - gesture handler should include flywheel component and should be part of CarouselView library
-(void)panGesture:(UIPanGestureRecognizer*)aGr {
    static CGPoint prevTranslation;
    if (aGr.state == UIGestureRecognizerStateBegan) {
        prevTranslation = CGPointZero;
    } else if (aGr.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [aGr translationInView:self.carouselView];
        
        float angle = (prevTranslation.x - translation.x) / 700.f;
        self.carouselView.angle += angle;
        
        prevTranslation = translation;
    }
}


@end
