// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "AppDelegate.hpp"
#import "MenuProtocol.hpp"
#import "InputControllerProtocol.hpp"
#include "MappingsWindowController.hpp"

@interface AppDelegate () {
    NSWindow * _window;
    IBOutlet NSMenu * _menu;
    MappingsWindowController * _mappingsController;
    id<InputControllerProtocol> __weak _inputController;
    NSWindowController * __weak _aboutController;
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

-(void) setCurrentInputController:(id<InputControllerProtocol>)controller {
    _inputController = controller;
}

-(void) setCurrentAboutController:(NSWindowController *)controller {
    _aboutController = controller;
}

-(NSString *) getVariantForLanguage:(NSString *)language {
    auto defs = NSUserDefaults.standardUserDefaults;
    auto variantKey = [language stringByAppendingString:@"_variant"];
    auto variant = [defs stringForKey:variantKey];
    return variant ? variant : @"";
}

-(void) setVariant:(NSString *)variant forLanguage:(NSString *)language {
    auto defs = NSUserDefaults.standardUserDefaults;
    auto variantKey = [language stringByAppendingString:@"_variant"];
    [defs setObject:variant forKey:variantKey];
    
    if (id<InputControllerProtocol> __strong inputController = _inputController; inputController) {
        auto currentLanguage = inputController.currentLanguage;
        if (currentLanguage && [currentLanguage isEqualToString:language])
            [inputController changeVariant:variant];
    }
}

-(void) displayMappingsForLanguage:(NSString *)language {
    if (!_mappingsController) {
        _mappingsController = [[MappingsWindowController alloc] initWithWindowNibName:@"mappings"];
        [_mappingsController.window setLevel:NSMainMenuWindowLevel];
    }
    [_mappingsController showLanguage:language];
    [_mappingsController showWindow:self];
    [_mappingsController.window orderFrontRegardless];
}

-(void) setMappingsLanguage:(NSString *)language {
    if (_mappingsController)
        [_mappingsController showLanguage:language];
}

-(void) deactivateUI {
    if (_mappingsController) {
        [_mappingsController close];
        _mappingsController = nil;
    }
    if (NSWindowController * __strong aboutController = _aboutController; aboutController) {
        [aboutController close];
    }
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
