// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "AppDelegate.h"
#include "MenuProtocol.h"

@interface AppDelegate () {
    NSWindow * _window;
    IBOutlet NSMenu * _menu;
}

@end

@implementation AppDelegate

-(void) awakeFromNib {
    if (NSMenuItem * preferences = [_menu itemWithTag:1]) {
        [preferences setAction:@selector(showPreferences:)];
    }
    if (NSMenuItem * bloop = [_menu itemWithTag:2]) {
        [bloop setAction:@selector(displayMappings:)];
    }
}

-(void) applicationWillFinishLaunching:(NSNotification *)notification {
}

-(void) applicationDidFinishLaunching:(NSNotification *)aNotification {
}

-(void) applicationWillTerminate:(NSNotification *)aNotification {
}

-(NSMenu *) menu {
    return _menu;
}


//- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
//    return YES;
//}


@end
