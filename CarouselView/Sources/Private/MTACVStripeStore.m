#import "MTACVStripeStore.h"
#import "MTACVDisplayStripe.h"
#import "CarouselViewItem.h"

#pragma mark MTACVStripeStore private interface

@interface MTACVStripeStore()

@end

#pragma mark - MTACVStripeStore implementation

@implementation MTACVStripeStore
@synthesize stripes, carouselView;
@synthesize prepared, displayed;

#pragma mark - MTACVStripeStore init methods

-(id)initWithStripes:(NSArray*)aStripes carouselView:(CarouselView*)aCarouselView {
    if ((self = [super init])) {
        carouselView = aCarouselView;
        stripes = aStripes;
        prepared = [NSMutableSet set];
        displayed = [NSMutableSet set];
    }
    return self;
}

-(void)dealloc {
    for (MTACVDisplayStripe* item in self.displayed) {
        [self hideStripe:item];
    }
    
    for (MTACVDisplayStripe* item in self.prepared) {
        [self freeStripe:item];
    }
}

#pragma mark - MTACVStripeStore public methods

-(void)prepareStripe:(MTACVDisplayStripe*)aStripe {
    if ([self.displayed containsObject:aStripe] || [self.prepared containsObject:aStripe]) {
        return;
    }
    
    if ([aStripe.item respondsToSelector:@selector(prepare:)]) {
        [aStripe.item prepare:self.carouselView];
    }
    [self.prepared addObject:aStripe];
}

-(void)displayStripe:(MTACVDisplayStripe*)aStripe {
    if ([self.displayed containsObject:aStripe]) {
        return;
    }
    
    if (![self.prepared containsObject:aStripe]) {
        [self prepareStripe:aStripe];
    }
    
    [self.prepared removeObject:aStripe];
    if ([aStripe.item respondsToSelector:@selector(display:)]) {
        [aStripe.item display:self.carouselView];
    }
    [self.displayed addObject:aStripe];
}

-(void)hideStripe:(MTACVDisplayStripe*)aStripe {
    if (![self.displayed containsObject:aStripe]) {
        return;
    }
    
    [self.displayed removeObject:aStripe];
    if ([aStripe.item respondsToSelector:@selector(hide:)]) {
        [aStripe.item hide:self.carouselView];
    }
    [self.prepared addObject:aStripe];
}

-(void)freeStripe:(MTACVDisplayStripe*)aStripe {
    if (![self.displayed containsObject:aStripe] && ![self.prepared containsObject:aStripe]) {
        return;
    }
    
    if ([self.displayed containsObject:aStripe]) {
        [self hideStripe:aStripe];
    }
    
    [self.prepared removeObject:aStripe];
    if ([aStripe.item respondsToSelector:@selector(free:)]) {
        [aStripe.item free:self.carouselView];
    }
}

-(BOOL)isStripeDisplayed:(MTACVDisplayStripe*)aStripe {
    return [self.displayed containsObject:aStripe];
}

@end
