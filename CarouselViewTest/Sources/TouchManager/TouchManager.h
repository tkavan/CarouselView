#import <Foundation/Foundation.h>

@protocol TouchManagerDelegate;

@interface TouchManager : NSObject

@property (nonatomic, weak) id<TouchManagerDelegate> delegate;
@property (nonatomic, weak) UIView* view;

@property (nonatomic, assign) BOOL flywheel;
@property (nonatomic, assign) CGFloat fraction;

-(id)initWithDelegate:(id<TouchManagerDelegate>)aDelegate;
+(TouchManager*)touchManagerWithDelegate:(id<TouchManagerDelegate>)aDelegate;

-(id)initWithDelegate:(id<TouchManagerDelegate>)aDelegate view:(UIView*)aView;
+(TouchManager*)touchManagerWithDelegate:(id<TouchManagerDelegate>)aDelegate view:(UIView*)aView;

-(void)tick:(CADisplayLink*)aDl;

@end
