#import <UIKit/UIKit.h>
#import "CarouselViewItem.h"
#import "CarouselViewImageItem.h"

@interface CarouselView : UIView

@property (nonatomic, strong) NSArray* items;

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign, readonly) CGFloat totalAngle;
@property (nonatomic, assign) CGFloat zoom; // not yet implemented
@property (nonatomic, assign, getter = isCyclic) BOOL cyclic; // not yet implemented (all carousel are cyclic now)
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat itemMargin; // not yet implemented
@property (nonatomic, strong) UIColor* backgroundColor; // not yet implemented

@property (nonatomic, copy) void(^tick)(CADisplayLink* aDl);

-(id)initWithFrame:(CGRect)aFrame radius:(CGFloat)aRadius;

-(id<CarouselViewItem>)tapOnPoint:(CGPoint)aPoint;

@end
