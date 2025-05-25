// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "MappingsWindowController.hpp"
#import "AppDelegate.hpp"

#include "Languages.hpp"

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
    NSMenuItem * selected;
    for (auto & entry: getVariantsForLanguage(_language)) {
        auto item = [menu addItemWithTitle:entry.displayName action:@selector(setMappingVariant:) keyEquivalent:@""];
        item.representedObject = entry.name;
        if ([_variant isEqualToString:entry.name])
            selected = item;
    }
    if (!selected)
        selected = menu.itemArray[0];
    [_schemeSelector setEnabled:menu.numberOfItems > 1];
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
    auto html_bytes = getHtmlFor(_language, _variant);
    if (html_bytes.empty()) {
        _text.hidden = YES;
        return;
    }
    auto html = [[NSString alloc] initWithBytes:html_bytes.data() length:html_bytes.size() encoding:NSUTF8StringEncoding];
    if (!html) {
        _text.hidden = YES;
        return;
    }
    _text.hidden = NO;
    [_text loadHTMLString:html baseURL:nil];
}

-(void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.getElementById('table-holder').scrollHeight"
              completionHandler:^(id result, NSError * err){
        if (err) {
            os_log_error(OS_LOG_DEFAULT, "Javascript failed: %{public}@", err);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), [weakSelf = makeWeak(self),result]() {
            auto self = makeStrong(weakSelf);
            if (!self)
                return;
            auto height = (NSNumber *)result;
            auto contentRect = self.window.contentLayoutRect;
            auto textFrame = self->_text.frame;
            auto minSize = self.window.contentMinSize;
            minSize.height = (contentRect.size.height - textFrame.size.height) + height.doubleValue;
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
