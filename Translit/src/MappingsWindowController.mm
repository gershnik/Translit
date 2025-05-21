// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "MappingsWindowController.hpp"
#import "AppDelegate.hpp"

@interface MappingsWindowController () <WKNavigationDelegate> {
    IBOutlet WKWebView * _text;
    IBOutlet NSPopUpButton * _schemeSelector;
    NSString * _language;
    NSString * _variant;
    bool _firstLoad;
}

@end

@implementation MappingsWindowController


-(void) windowDidLoad {
    [super windowDidLoad];
    _text.navigationDelegate = self;
    _firstLoad = true;
    [self showLanguage:_language];
}

-(void) showLanguage:(NSString *)language {
    if (!language)
        return;
    if (_language && [_language isEqualToString:language])
        return;
    _language = language;
    if (!_text || !_schemeSelector)
        return;
    
    _variant = [(AppDelegate *)NSApp.delegate getVariantForLanguage:_language];
    
    auto menu = _schemeSelector.menu;
    [menu removeAllItems];
    auto item = [menu addItemWithTitle:@"default" action:@selector(setMappingVariant:) keyEquivalent:@""];
    item.representedObject = @"";
    NSMenuItem * selected = item;
    if ([_language isEqualToString:@"ru"]) {
        item = [menu addItemWithTitle:@"translit.ru" action:@selector(setMappingVariant:) keyEquivalent:@""];
        item.representedObject = @"translit-ru";
        if ([_variant isEqualToString:@"translit-ru"])
            selected = item;
        
        [_schemeSelector setEnabled:YES];
    } else {
        [_schemeSelector setEnabled:NO];
    }
    [_schemeSelector selectItem:selected];
    [_schemeSelector synchronizeTitleAndSelectedItem];
    
    _firstLoad = true;
    [self updateTable];
}

-(IBAction) setMappingVariant:(id)sender {
    auto item = _schemeSelector.selectedItem;
    if (!item)
        return;
    _variant = (NSString *)item.representedObject;
    [_schemeSelector selectItem:item];
    [_schemeSelector synchronizeTitleAndSelectedItem];
    [self updateTable];
    auto del = (AppDelegate *)NSApp.delegate;
    [del setVariant:_variant forLanguage:_language];    
}

-(void) updateTable {
    auto name = [@"mapping-" stringByAppendingString:_language];
    if (_variant.length)
        name = [[name stringByAppendingString:@"."] stringByAppendingString:_variant];
    auto url = [NSBundle.mainBundle URLForResource:name withExtension:@"html"];
    auto html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [_text loadHTMLString:html baseURL:nil];
}

-(void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.getElementById('table-holder').scrollHeight"
              completionHandler:^(id result, NSError * err){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (err)
                return;
            auto height = (NSNumber *)result;
            auto contentRect = self.window.contentLayoutRect;
            auto textFrame = self->_text.frame;
            auto minSize = self.window.contentMinSize;
            minSize.height = (contentRect.size.height - textFrame.size.height) + height.doubleValue;
            os_log_info(OS_LOG_DEFAULT, "HAHAHA %{public}lf %{public}lf", contentRect.size.height, minSize.height);
            [self.window setContentMinSize:minSize];
            if (self->_firstLoad || contentRect.size.height < minSize.height)
                [self.window setContentSize:{contentRect.size.width, minSize.height}];
            self->_firstLoad = false;
        });
    }];
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
