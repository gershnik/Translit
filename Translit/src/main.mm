// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "AppDelegate.h"

enum class AppLocation {
    System,
    User,
    Other
};

static auto getAppLocation() -> AppLocation {
    auto userInputMethods = [NSFileManager.defaultManager URLForDirectory:NSInputMethodsDirectory
                                                                 inDomain:NSUserDomainMask
                                                        appropriateForURL:nil
                                                                   create:false
                                                                    error:nil];
    auto systemInputMethods = [NSFileManager.defaultManager URLForDirectory:NSInputMethodsDirectory
                                                                   inDomain:NSLocalDomainMask
                                                          appropriateForURL:nil
                                                                     create:false
                                                                      error:nil];
    auto parent = NSBundle.mainBundle.bundleURL.URLByStandardizingPath.URLByDeletingLastPathComponent;
    if ([userInputMethods isEqualTo:parent])
        return AppLocation::User;
    if ([systemInputMethods isEqualTo:parent])
        return AppLocation::System;
    return AppLocation::Other;
}

static auto registerOurselves() -> int {
    if (getAppLocation() == AppLocation::Other) {
        fprintf(stderr, "This application is not installed\n");
        return EXIT_FAILURE;
    }
    
    auto bundle = NSBundle.mainBundle;
    auto url = bundle.bundleURL.URLByStandardizingPath;
    OSStatus res = TISRegisterInputSource((__bridge CFURLRef)url);
    if (res != noErr) {
        fprintf(stderr, "Unable to register input source: OSStatus %d\n", res);
        return EXIT_FAILURE;
    }
    //in case we were already running
    [NSDistributedNotificationCenter.defaultCenter postNotificationName:@"AppleLanguagePreferencesChangedNotification" object:nil];
    return EXIT_SUCCESS;
}

static auto uninstallOurselves() -> int {
    
    dispatch_async(dispatch_get_main_queue(),^{
        auto appLocation = getAppLocation();
        if (appLocation == AppLocation::Other) {
            fprintf(stderr, "This application is not installed\n");
            exit(EXIT_FAILURE);
        }
        
        if (appLocation == AppLocation::System) {
            if (getuid() != 0) {
                fprintf(stderr, "You must be root to uninstall this application\n");
                exit(EXIT_FAILURE);
            }
        }
        
        auto bundle = NSBundle.mainBundle;
        auto url = bundle.bundleURL.URLByStandardizingPath;
        auto * bundleId = bundle.bundleIdentifier;
            
        auto props = @{
            (__bridge NSString*)kTISPropertyBundleID : bundleId,
            (__bridge NSString*)kTISPropertyInputSourceType: (__bridge NSString*)kTISTypeKeyboardInputMode
        };
        NSArray * sources = (__bridge_transfer NSArray *)TISCreateInputSourceList((__bridge CFDictionaryRef)props, false);
        for(NSObject * src in sources) {
            auto cfSrc = (__bridge TISInputSourceRef)src;
            auto enabled = (CFBooleanRef)TISGetInputSourceProperty(cfSrc, kTISPropertyInputSourceIsEnabled);
            if (enabled != kCFBooleanTrue)
                continue;
            OSStatus res = TISDisableInputSource(cfSrc);
            if (res != noErr) {
                auto typeId = (__bridge NSString *)(CFStringRef)TISGetInputSourceProperty(cfSrc, kTISPropertyInputSourceID);
                fprintf(stderr, "Unable to disable input source %s: OSStatus %d\n", typeId.UTF8String, res);
            }
        }
        
        auto nc = NSDistributedNotificationCenter.defaultCenter;
        [nc postNotificationName:@"AppleEnabledInputSourcesChangedNotification" object:nil];
        [nc postNotificationName:@"com.apple.Carbon.TISNotifyEnabledKeyboardInputSourcesChanged" object:nil];
        
        
        auto runningInstances = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleId];
        for (NSRunningApplication * app in runningInstances) {
            if ([app.bundleURL.URLByStandardizingPath isEqualTo:url]) {
                auto pid = app.processIdentifier;
                if (pid > 0 && pid != getpid()) {
                    fprintf(stdout, "Terminating Translit process %d\n", pid);
                    kill(pid, SIGKILL);
                    break;
                }
            }
        }
        
        fprintf(stdout, "Moving %s to trash\n", url.fileSystemRepresentation);
        NSError * err;
        if (![NSFileManager.defaultManager trashItemAtURL:url resultingItemURL:nil error:&err]) {
            fprintf(stderr, "Unable to trash: code %ld, %s\n", long(err.code), err.description.UTF8String);
            exit(EXIT_FAILURE);
        }
        
        
        [nc postNotificationName:@"AppleLanguagePreferencesChangedNotification" object:nil];
        
        auto args = @[@"pkgutil", @"--forget", bundleId];
        if (appLocation == AppLocation::User) {
            auto volArg = [@"--volume=" stringByAppendingString:NSHomeDirectory()];
            args = [args arrayByAddingObject:volArg];
        }
        [NSTask launchedTaskWithExecutableURL:[NSURL fileURLWithPath:@"/usr/sbin/pkgutil"]
                                    arguments:args
                                        error:&err
                           terminationHandler:^(NSTask * task) {
            if (task.terminationStatus != 0)
                exit(EXIT_FAILURE);
            
            printf("Translit has been successfully uninstalled. It is recommended you log off and log back on (or restart) to ensure System Settings retains no spurious record of it.\n");
            
            exit(EXIT_SUCCESS);
        }];
        
        if (err) {
            fprintf(stderr, "Unable to launch pkgutil: code %ld, %s\n", long(err.code), err.description.UTF8String);
            exit(EXIT_FAILURE);
        }
    });
    [NSRunLoop.mainRunLoop run];
    
    
    return EXIT_SUCCESS;
}

auto main(int argc, const char * argv[]) -> int {
    for(int i = 0; i < argc; ++i) {
        if (strcasecmp(argv[i], "--register") == 0) {
            return registerOurselves();
        } else if (strcasecmp(argv[i], "--uninstall") == 0) {
            return uninstallOurselves();
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
