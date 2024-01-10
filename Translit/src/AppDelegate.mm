// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "AppDelegate.hpp"
#import "MenuProtocol.hpp"
#include "MappingsWindowController.hpp"

@interface AppDelegate () {
    NSWindow * _window;
    IBOutlet NSMenu * _menu;
    MappingsWindowController * _mappingsController;
}

@end

@implementation AppDelegate

-(void) awakeFromNib {
    if (NSMenuItem * preferences = [_menu itemWithTag:1]) {
        [preferences setAction:@selector(showPreferences:)];
    }
    if (NSMenuItem * displayMappings = [_menu itemWithTag:2]) {
        [displayMappings setAction:@selector(displayMappings:)];
    }
}

static void bundleWatchCallback(ConstFSEventStreamRef streamRef,
                                void * clientCallBackInfo,
                                size_t numEvents,
                                void * eventPaths,
                                const FSEventStreamEventFlags * eventFlags,
                                const FSEventStreamEventId * eventIds) {
 
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

-(void) displayMappingsForLanguage:(NSString *)language {
    if (!_mappingsController) {
        _mappingsController = [[MappingsWindowController alloc] initWithWindowNibName:@"mappings"];
        [_mappingsController.window setLevel:NSMainMenuWindowLevel];
    }
    _mappingsController.language = language;
    [_mappingsController showWindow:self];
    [_mappingsController.window orderFrontRegardless];
}

-(void) setMappingsLanguage:(NSString *)language {
    if (_mappingsController)
        _mappingsController.language = language;
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
