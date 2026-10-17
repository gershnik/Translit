// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "AppDelegate.hpp"
#import "MenuProtocol.hpp"
#import "InputControllerProtocol.hpp"
#import "MappingsWindowController.hpp"
#import "AboutWindowController.hpp"

@interface AppDelegate () {
    NSWindow * _window;
    IBOutlet NSMenu * _menu;
    MappingsWindowController * _mappingsController;
    AboutWindowController * _aboutController;
    NSString * _lastMappingsLanguage;
}

@end

@implementation AppDelegate

-(void) awakeFromNib {
    if (NSMenuItem * preferences = [_menu itemWithTag:1]) {
        [preferences setAction:@selector(displayAbout:)];
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
        if (eventFlags[i] & kFSEventStreamEventFlagRootChanged) {
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

- (void) application:(NSApplication *)app openURLs:(NSArray<NSURL *> *)urls {
    bool showMappings = false;
    bool showAbout = false;
    for(NSURL * url in urls) {
        auto * components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];
        if ([components.scheme isEqualToString:@"translit"]) {
            if ([components.host isEqualToString:@"show-mappings"])
                showMappings = true;
            else if ([components.host isEqualToString:@"about"])
                showAbout = true;
        }
    }
    
    if (showMappings) {
        if (_lastMappingsLanguage)
            [self displayMappingsForLanguage:_lastMappingsLanguage];
    }
    if (showAbout) {
        [self displayAbout];
    }
}

-(void) applicationWillTerminate:(NSNotification *)aNotification {
}

-(NSMenu *) menu {
    return _menu;
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

-(void) displayAbout {
    if (!_aboutController) {
        _aboutController = [[AboutWindowController alloc] initWithWindowNibName:@"preferences"];
        [_aboutController.window setLevel:NSMainMenuWindowLevel];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(aboutControllerWindowClosed:)
                                                   name:NSWindowWillCloseNotification
                                                 object:_aboutController.window];
    }
    [_aboutController showWindow:self];
    [_aboutController.window orderFrontRegardless];
}

- (void) aboutControllerWindowClosed:(NSNotification *)notification {
    auto window = (NSWindow *)notification.object;
    auto controller = window.windowController;
    [NSNotificationCenter.defaultCenter removeObserver:self name:NSWindowWillCloseNotification object:window];
    
    if (_aboutController == controller) {
        _aboutController = nil;
    }
}

-(void) setMappingsLanguage:(NSString *)language {
    _lastMappingsLanguage = language;
    if (_mappingsController)
        [_mappingsController showLanguage:language];
}

-(void) deactivateUI {
    _lastMappingsLanguage = nil;
    if (_mappingsController) {
        [_mappingsController close];
        _mappingsController = nil;
    }
    if (_aboutController) {
        [_aboutController close];
        _aboutController = nil;
    }
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
