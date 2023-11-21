// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later


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

static auto execute(NSString * exe, NSArray<NSString *> * args, bool sudo = false) -> std::pair<int, int> {
    
    posix_spawn_file_actions_t fileActions;
    posix_spawn_file_actions_init(&fileActions);
    posix_spawn_file_actions_addinherit_np(&fileActions, STDIN_FILENO);
    posix_spawn_file_actions_addinherit_np(&fileActions, STDOUT_FILENO);
    posix_spawn_file_actions_addinherit_np(&fileActions, STDERR_FILENO);
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_CLOEXEC_DEFAULT | POSIX_SPAWN_SETSIGDEF);
    
    auto exeUrl = [NSURL fileURLWithPath:exe].URLByStandardizingPath;
    std::string path;
    std::vector<std::string> extras;
    if (!sudo) {
        path = exeUrl.fileSystemRepresentation;
        extras.assign({exeUrl.lastPathComponent.UTF8String});
    } else {
        path = "/usr/bin/sudo";
        extras.assign({"sudo", exeUrl.fileSystemRepresentation});
    }
    
    std::vector<const char *> rawArgs;
    rawArgs.reserve(extras.size() + args.count + 1);
    for(auto & extra: extras)
        rawArgs.push_back(extra.c_str());
    for(NSString * arg in args)
        rawArgs.push_back(arg.UTF8String);
    rawArgs.push_back(nullptr);
    
    pid_t pid;
    int spawnRes = posix_spawn(&pid, path.c_str(), &fileActions, &attr, (char **)rawArgs.data(), nullptr);
    int err = errno;
    posix_spawn_file_actions_destroy(&fileActions);
    posix_spawnattr_destroy(&attr);
    if (spawnRes) {
        return {err, 0};
    }
    int stat;
    pid_t res = waitpid(pid, &stat, 0);
    if (res < 0) {
        return {errno, 0};
    }
    assert(res == pid);
    if (WIFEXITED(stat))
        return {0, WEXITSTATUS(stat)};
    
    return {0, 128 + WTERMSIG(stat)};
}

static auto sendAppleEventToSystemProcess(AEEventID eventToSend) -> OSStatus
{
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    struct TargetDescHolder {
        AEAddressDesc targetDesc;
        bool needToDispose = false;
        
        ~TargetDescHolder() {
            if (needToDispose)
                AEDisposeDesc(&targetDesc);
        }
    } targetDescHolder;
    
    if (auto error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess,
                                  sizeof(kPSNOfSystemProcess), &targetDescHolder.targetDesc);
        error != noErr) {
        return error;
    }
    targetDescHolder.needToDispose = true;
    
    AppleEvent appleEventToSend = {typeNull, nullptr};
    if (auto error = AECreateAppleEvent(kCoreEventClass, eventToSend, &targetDescHolder.targetDesc,
                                        kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
        error != noErr) {
        return error;
    }

    AppleEvent eventReply = {typeNull, nullptr};
    return AESend(&appleEventToSend, &eventReply, kAENoReply,
                  kAENormalPriority, kAEDefaultTimeout, NULL, NULL);

}

auto uninstallApplication() -> int {
    
    auto appLocation = getAppLocation();
    if (appLocation == AppLocation::Other) {
        fprintf(stderr, "This application instance is not installed\n");
        exit(EXIT_FAILURE);
    }
    
    auto bundle = NSBundle.mainBundle;
    auto url = bundle.bundleURL.URLByStandardizingPath;
    auto * bundleId = bundle.bundleIdentifier;
        
    {
        printf("Removing %s\n", url.fileSystemRepresentation);
        auto [err, stat] = execute(@"/bin/rm", @[@"-rf", @( url.fileSystemRepresentation )],
                                   appLocation == AppLocation::System);
        if (err) {
            fprintf(stderr, "Unable to remove application bundle, code: %d\n", err);
            return EXIT_FAILURE;
        }
        if (stat) {
            fprintf(stderr, "Removal failed with exit code %d\n", stat);
            return EXIT_FAILURE;
        }
    }
    
            
    {
        printf("Removing installed package info (if any)...\n");
        auto args = @[@"--forget", bundleId];
        if (appLocation == AppLocation::User)
            args = [args arrayByAddingObject:[@"--volume=" stringByAppendingString:NSHomeDirectory()]];
        auto [err, stat] = execute(@"/usr/sbin/pkgutil", args, appLocation == AppLocation::System);
        if (err) {
            fprintf(stderr, "Unable to launch pkgutil: code %d\n", err);
        }
        if (stat) {
            fprintf(stderr, "pkgutil failed with exit code %d\n", stat);
        }
    }
    
    if (auto err = sendAppleEventToSystemProcess(kAELogOut); err != noErr) {
        fprintf(stderr, "Unable to request logout: OSStatus %ld\n", long(err));
    }
            
    printf("Translit has been successfully uninstalled.\n"
           "You must log off and log back on (or restart) to fully remove it from the system\n");
                
    return EXIT_SUCCESS;
}
