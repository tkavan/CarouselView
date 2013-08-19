#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class CarouselView;

@protocol CarouselViewItem <NSObject>

@required
@property (nonatomic, strong, readonly) GLKTextureInfo* texture;
@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, strong, readonly) UIColor* backgroundColor;

@optional
-(void)prepare:(CarouselView*)aCarouselView;
-(void)display:(CarouselView*)aCarouselView;
-(void)hide:(CarouselView*)aCarouselView;
-(void)free:(CarouselView*)aCarouselView;

-(void)didMoveAtPoint:(CGPoint)aPoint inCarouselView:(CarouselView*)aCarouselView;

// TODO touch methods (add here or add to CarouselView delegate)

@end
