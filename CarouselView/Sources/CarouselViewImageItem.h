#import <Foundation/Foundation.h>
#import "CarouselViewItem.h"

@interface CarouselViewImageItem : NSObject<CarouselViewItem>

@property (nonatomic, strong, readonly) UIImage* image;
@property (nonatomic, strong) UIColor* backgroundColor;

-(id)initWithPath:(NSString*)aPath;
-(id)initWithImage:(UIImage*)aImage;

@end
