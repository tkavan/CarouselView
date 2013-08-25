#import <Foundation/Foundation.h>

@class TouchManager;

@protocol TouchManagerDelegate <NSObject>

@optional
-(void)touchManager:(TouchManager*)aManager didPan:(CGPoint)aDistance velocity:(CGPoint)aVelocity;
-(void)touchManager:(TouchManager*)aManager didOneTap:(CGPoint)aPosition;

@end
