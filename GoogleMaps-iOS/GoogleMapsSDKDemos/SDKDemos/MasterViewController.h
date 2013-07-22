#import <UIKit/UIKit.h>

@class SDKDemosAppDelegate;

@interface MasterViewController : UITableViewController <
    UISplitViewControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic, assign) SDKDemosAppDelegate *appDelegate;

@end
