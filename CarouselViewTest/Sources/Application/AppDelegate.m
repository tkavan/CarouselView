#import "AppDelegate.h"
#import "ViewController.h"
#import "AppFactory.h"

@interface AppDelegate()

@property (nonatomic, strong) AppFactory* appFactory;

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    self.appFactory = [[AppFactory alloc] init];
    self.window = [self.appFactory buildMainWindow];
    return YES;
}

@end
