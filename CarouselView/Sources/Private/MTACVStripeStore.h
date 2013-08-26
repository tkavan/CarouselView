#import <Foundation/Foundation.h>

@class MTACVDisplayStripe;
@class CarouselView;

@interface MTACVStripeStore : NSObject

@property (nonatomic, strong, readonly) NSArray* stripes;
@property (nonatomic, weak, readonly) CarouselView* carouselView;

@property (nonatomic, strong, readonly) NSMutableSet* prepared;
@property (nonatomic, strong, readonly) NSMutableSet* displayed;

-(id)initWithStripes:(NSArray*)aStripes carouselView:(CarouselView*)aCarouselView;

-(void)prepareStripe:(MTACVDisplayStripe*)aStripe;
-(void)displayStripe:(MTACVDisplayStripe*)aStripe;
-(void)hideStripe:(MTACVDisplayStripe*)aStripe;
-(void)freeStripe:(MTACVDisplayStripe*)aStripe;

-(BOOL)isStripeDisplayed:(MTACVDisplayStripe*)aStripe;

@end
