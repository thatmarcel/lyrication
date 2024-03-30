#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <Cephei/HBPreferences.h>
#import <spawn.h>

@interface LyricationPrefsController : HBRootListController {
    UITableView* _table;
}
@end