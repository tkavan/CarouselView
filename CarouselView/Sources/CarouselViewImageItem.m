#import "CarouselViewImageItem.h"
#import <GLKit/GLKit.h>

#pragma mark CarouselViewImageItem private interface

@interface CarouselViewImageItem()

@property (nonatomic, strong) GLKTextureLoader* loader;
@property (nonatomic, strong) NSString* path;
@property (assign) BOOL loading;

@end

#pragma mark - CarouselViewImageItem implementation

@implementation CarouselViewImageItem
@synthesize image;
@synthesize texture, size, backgroundColor;
@synthesize loader, path, loading;

#pragma mark - CarouselViewImageItem init methods

-(id)initWithPath:(NSString*)aPath {
    UIImage* aImage = [UIImage imageNamed:aPath];
    self = [self initWithImage:aImage];
    self.path = aPath;
    return self;
}

-(id)initWithImage:(UIImage*)aImage {
    if ((self = [super init])) {
        image = aImage;
        size = aImage.size;
        path = [NSString stringWithFormat:@"In memory: %@", image];
        loading = NO;
    }
    return self;
}

#pragma mark - CarouselItemView delegate methods

-(void)prepare:(CarouselView*)aCarouselView {
    if (self.texture || self.loading) {
        return;
    }
    self.loading = YES;
    
    if (!self.loader) {
        self.loader = [[GLKTextureLoader alloc] initWithSharegroup:[EAGLContext currentContext].sharegroup];
    }
    
    NSLog(@"Loading: %@", self.path);
    [self.loader textureWithCGImage:self.image.CGImage
                            options:nil
                              queue:NULL
                  completionHandler: ^(GLKTextureInfo* aInfo, NSError* aErr) {
                      texture = aInfo;
                      if (aErr) {
                          NSLog(@"Error: %@ (%@)", self.path, aErr);
                      } else {
                          NSLog(@"Loaded: %@", self.path);
                      }
                      self.loading = NO;
                  }];
}

-(void)free:(CarouselView*)aCarouselView {
    GLKTextureInfo* info = self.texture;
    texture = nil;
    if (info) {
        GLuint name = info.name;
        glDeleteTextures(1, &name);
        NSLog(@"Free: %@", self.path);
    }
}

@end
