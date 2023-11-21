// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "AppDelegate.h"
#import "Uninstall.h"


auto main(int argc, const char * argv[]) -> int {
    for(int i = 0; i < argc; ++i) {
        if (strcasecmp(argv[i], "--uninstall") == 0) {
            return uninstallApplication();
        }
    }
    @autoreleasepool {
        auto bundle = NSBundle.mainBundle;
        NSString * connectionName = [bundle objectForInfoDictionaryKey:@"InputMethodConnectionName"];
        auto server = [[IMKServer alloc] initWithName:connectionName
                                     bundleIdentifier:bundle.bundleIdentifier];
        NSString * mainNib = [bundle objectForInfoDictionaryKey:@"NSMainNibFile"];
        [bundle loadNibNamed:mainNib owner:NSApp topLevelObjects:nil];
        [[maybe_unused]]
        auto candidates = [[IMKCandidates alloc] initWithServer:server
                                                      panelType:kIMKSingleColumnScrollingCandidatePanel
                                                      styleType:kIMKMain];
        [NSApp run];
    }
}
