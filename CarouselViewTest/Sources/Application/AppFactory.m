#import "AppFactory.h"
#import "ViewController.h"

#pragma mark AppFactory private interface

@interface AppFactory()

-(ViewController*)buildViewController;

+(NSString*)deviceSpecificNibName:(NSString*)aNibName;

@end

#pragma mark - AppFactory implementation

@implementation AppFactory

#pragma mark - AppFactory private class methods

+(NSString*)deviceSpecificNibName:(NSString*)aNibName {
    NSString* retString = aNibName;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        retString = [aNibName stringByAppendingString:@"~iPad"];
    }
    return retString;
}

#pragma mark - AppFactory build window method

-(UIWindow*)buildMainWindow {
    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [self buildViewController];
    [window makeKeyAndVisible];
    return window;
}

#pragma mark - AppFactory build view controllers methods

-(ViewController*)buildViewController {
    NSString* nibName = [AppFactory deviceSpecificNibName:@"ViewController"];
    ViewController* vc = [[ViewController alloc] initWithNibName:nibName bundle:nil];
    return vc;
}

@end
