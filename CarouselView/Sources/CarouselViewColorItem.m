#import "CarouselViewColorItem.h"

#pragma mark CarouselViewColorItem private interface

@implementation CarouselViewColorItem
@synthesize texture, size, backgroundColor;

#pragma mark - CarouselViewColorItem init methods

-(id)initWithColor:(UIColor*)aColor size:(CGSize)aSize {
    if ((self = [super init])) {
        backgroundColor = aColor;
        size = aSize;
        texture = nil;
    }
    return self;
}

@end
