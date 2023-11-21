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

static void bundleWatchCallback(ConstFSEventStreamRef streamRef,
                                void * clientCallBackInfo,
                                size_t numEvents,
                                void * eventPaths,
                                const FSEventStreamEventFlags * eventFlags,
                                const FSEventStreamEventId * eventIds) {
 
    //auto paths = (__bridge NSArray<NSString *> *)(CFArrayRef)eventPaths;
    for(size_t i = 0; i < numEvents; ++i) {
        if (eventFlags[i] == kFSEventStreamEventFlagRootChanged) {
            exit(0);
        }
    }
}

-(void) applicationWillFinishLaunching:(NSNotification *)notification {
    
    auto pathsToWatch = @[@(NSBundle.mainBundle.bundleURL.URLByStandardizingPath.fileSystemRepresentation)];
    CFAbsoluteTime latency = 1.0; // seconds
    auto stream = FSEventStreamCreate(nullptr,
                                      bundleWatchCallback,
                                      nullptr,
                                      (__bridge CFArrayRef)pathsToWatch,
                                      kFSEventStreamEventIdSinceNow,
                                      latency,
                                      kFSEventStreamCreateFlagWatchRoot /*| kFSEventStreamCreateFlagUseCFTypes*/);
    FSEventStreamSetDispatchQueue(stream, dispatch_get_main_queue());
    FSEventStreamStart(stream);
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
