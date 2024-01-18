// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "AboutWindowController.hpp"

@interface AboutWindowController () <WKNavigationDelegate> {
    IBOutlet WKWebView * _text;
}

@end

@implementation AboutWindowController

-(void) windowDidLoad {
    [super windowDidLoad];
    auto bundle = NSBundle.mainBundle;
    auto url = [bundle URLForResource:@"about" withExtension:@"html"];
    auto html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSString * version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    html = [html stringByReplacingOccurrencesOfString:@"%VERSION%" withString:version];
    NSString * copyright = [bundle objectForInfoDictionaryKey:@"NSHumanReadableCopyright"];
    html = [html stringByReplacingOccurrencesOfString:@"%COPYRIGHT%" withString:copyright];
    auto iconUrl = [bundle URLForImageResource:@"AppIcon"];
    auto iconImage = [[NSImage alloc] initWithContentsOfURL:iconUrl];
    auto tiffData = iconImage.TIFFRepresentation;
    auto tiffStr = [tiffData base64EncodedStringWithOptions:0];
    auto srcStr = [@"data:image/tiff;base64, " stringByAppendingString:tiffStr];
    html = [html stringByReplacingOccurrencesOfString:@"%ICONURL%" withString:srcStr];
    
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
    
    NSString * dir;
    if ([userInputMethods isEqualTo:parent]) {
        dir = @( userInputMethods.fileSystemRepresentation );
    } else if ([systemInputMethods isEqualTo:parent]) {
        dir = @( systemInputMethods.fileSystemRepresentation );
    }
    
    if (dir.length > 0) {
        auto prefix = [dir stringByAppendingString:@"/"];
        auto exePath = bundle.executablePath;
        auto subPath = [exePath stringByReplacingOccurrencesOfString:prefix
                                                          withString:@""
                                                             options:NSAnchoredSearch
                                                               range:{0, exePath.length}];
        auto command = [NSString stringWithFormat:@"cd \"%@\"<br/>%@ --uninstall", dir, subPath];
        html = [html stringByReplacingOccurrencesOfString:@"%COMMAND_VISIBILITY%" withString:@"visible"];
        html = [html stringByReplacingOccurrencesOfString:@"%COMMAND%" withString:command];
    } else {
        html = [html stringByReplacingOccurrencesOfString:@"%COMMAND_VISIBILITY%" withString:@"hidden"];
    }
    
    
    [_text loadHTMLString:html baseURL:nil];
    _text.navigationDelegate = self;
}

-(void) webView:(WKWebView *)webView 
        decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                        decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        auto url = navigationAction.request.URL;
        os_log_debug(OS_LOG_DEFAULT, "Navigating to link:  %{public}@", url);
        [NSWorkspace.sharedWorkspace openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

@end
