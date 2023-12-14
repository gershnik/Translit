// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "AppDelegate.hpp"
#import "Uninstall.hpp"


auto main(int argc, const char * argv[]) -> int {
    for(int i = 0; i < argc; ++i) {
        if (strcasecmp(argv[i], "--uninstall") == 0) {
            return uninstallApplication();
        }
    }
    @autoreleasepool {
        auto bundle = NSBundle.mainBundle;
        NSString * connectionName = [bundle objectForInfoDictionaryKey:@"InputMethodConnectionName"];
        [[maybe_unused]]
        auto server = [[IMKServer alloc] initWithName:connectionName
                                     bundleIdentifier:bundle.bundleIdentifier];
        NSString * mainNib = [bundle objectForInfoDictionaryKey:@"NSMainNibFile"];
        [bundle loadNibNamed:mainNib owner:NSApp topLevelObjects:nil];
        [NSApp run];
    }
}
