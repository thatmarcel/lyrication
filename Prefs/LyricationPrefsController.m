#import "LyricationPrefsController.h"
#import "lx_root_helper.h"

@implementation LyricationPrefsController
    + (nullable NSString*) hb_specifierPlist {
	    return @"Root";
    }

    - (nullable NSString*) hb_specifierPlist {
	    return @"Root";
    }

    - (instancetype) init {
        self = [super init];

        if (self) {
            UIBarButtonItem* respringItem = [[UIBarButtonItem alloc]
                initWithTitle: @"Respring"
				style: UIBarButtonItemStylePlain
				target: self
				action: @selector(respring:)
            ];
	    	self.navigationItem.rightBarButtonItem = respringItem;
        }

        return self;
    }

    - (void) respring:(id)sender {
        pid_t pid;
	    const char* args[] = { "sbreload", NULL };
	    posix_spawn(&pid, LX_CONVERT_JBROOT_PATH_CSTRING("/usr/bin/sbreload"), NULL, NULL, (char* const*) args, NULL);
    }

@end