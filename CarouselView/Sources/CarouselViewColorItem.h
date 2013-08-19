#import <Foundation/Foundation.h>
#import "CarouselViewItem.h"

@interface CarouselViewColorItem : NSObject<CarouselViewItem>

-(id)initWithColor:(UIColor*)aColor size:(CGSize)aSize;

@end
