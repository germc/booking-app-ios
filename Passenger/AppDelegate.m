/******************************************************************************
 *
 * Copyright (C) 2013 T Dispatch Ltd
 *
 * Licensed under the GPL License, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.gnu.org/licenses/gpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************
 *
 * @author Marcin Orlowski <marcin.orlowski@webnet.pl>
 *
 ****/

#import "AppDelegate.h"
#import "UserSettings.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray* files = @[@"strings_address_search",
                       @"strings_booking_list",
                       @"strings_demo",
                       @"strings_dialog",
                       @"strings_generic",
                       @"strings_main_menu",
                       @"strings_map",
                       @"strings_new_booking_dialog",
                       @"strings_oauth",
                       @"strings_office",
                       @"strings_profile",
                       @"strings_pulltorefresh",
                       @"strings_register",
                       @"strings_slide_menu",
                       @"strings_tdfragment",
                       @"strings_tour",
                       @"strings_translator_credits"];
    NSArray* languages = @[@"de", @"en", @"es", @"fr", @"it", @"ja", @"ko", @"ms", @"pl", @"ru", @"sv", @"th", @"uk", @"zh-Hans", @"zh-Hant" ];
    
    for (NSString *language in languages)
    {
        [[NSBundle mainBundle] addStringFiles:files forLanguage:language];
    }

#ifdef TEST_FLIGHT
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#warning add your test flight token here
    [TestFlight takeOff:@""];
#endif
    
#error "add your google API key here"
    [GMSServices provideAPIKey:@"your_google_maps_api_key"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:DEVICE_STORYBOARD
                                                         bundle:nil];
    UINavigationController* vc = [storyboard instantiateViewControllerWithIdentifier:@"startNavigationController"];

    self.window.rootViewController = vc;
    self.window.backgroundColor = [UIColor backgroundColor];
    [self.window makeKeyAndVisible];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
