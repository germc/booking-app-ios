#import "SDKDemos/APIKey.h"
#import "SDKDemos/MasterViewController.h"
#import "SDKDemos/SDKDemosAppDelegate.h"

#import <GoogleMaps/GoogleMaps.h>

@implementation SDKDemosAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  if ([APIKey length] == 0) {
    // Blow up if APIKey has not yet been set.
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *reason =
        [NSString stringWithFormat:@"Configure APIKey inside APIKey.h for your "
         @"bundle `%@`, see README.GoogleMapsSDKDemos for more information",
         bundleId];
    @throw [NSException exceptionWithName:@"SDKDemosAppDelegate"
                                   reason:reason
                                 userInfo:nil];
  }
  [GMSServices provideAPIKey:(NSString *)APIKey];

  NSLog(@"Open-source licenses info:\n%@\n",
        [GMSServices openSourceLicenseInfo]);

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  MasterViewController *master = [[MasterViewController alloc] init];
  master.appDelegate = self;

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    // This is an iPhone; configure the top-level navigation controller as the
    // rootViewController, which contains the 'master' list of samples.
    self.navigationController =
        [[UINavigationController alloc] initWithRootViewController:master];
    self.window.rootViewController = self.navigationController;
  } else {
    // This is an iPad; configure a split-view controller that contains the
    // the 'master' list of samples on the left side, and the current displayed
    // sample on the right (begins empty).
    UINavigationController *masterNavigationController =
        [[UINavigationController alloc] initWithRootViewController:master];

    UIViewController *empty = [[UIViewController alloc] init];
    UINavigationController *detailNavigationController =
        [[UINavigationController alloc] initWithRootViewController:empty];

    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = master;
    self.splitViewController.viewControllers =
        @[masterNavigationController, detailNavigationController];
    self.splitViewController.presentsWithGesture = NO;

    self.window.rootViewController = self.splitViewController;
  }

  [self.window makeKeyAndVisible];
  return YES;
}

- (void)setSample:(UIViewController *)sample {
  NSAssert([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad,
           @"Expected device to be iPad inside setSample:");

  // Finds the UINavigationController in the right side of the sample, and
  // replace its displayed controller with the new sample.
  UINavigationController *nav =
      [self.splitViewController.viewControllers objectAtIndex:1];
  [nav setViewControllers:[NSArray arrayWithObject:sample] animated:NO];
}

- (UIViewController *)sample {
  NSAssert([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad,
           @"Expected device to be iPad inside sample");

  // The current sample is the top-most VC in the right-hand pane of the
  // splitViewController.
  UINavigationController *nav =
      [self.splitViewController.viewControllers objectAtIndex:1];
  return [[nav viewControllers] objectAtIndex:0];
}

@end
