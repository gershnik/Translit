// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "MappingsWindowController.hpp"
#import "AppDelegate.hpp"

@interface MappingsWindowController () {
    IBOutlet NSImageView * _text;
    IBOutlet NSPopUpButton * _schemeSelector;
    NSString * _language;
    NSString * _variant;
}

@end

@implementation MappingsWindowController


-(void) windowDidLoad {
    [super windowDidLoad];
    [_text setWantsLayer:true];
    _text.layer.backgroundColor = NSColor.whiteColor.CGColor;
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
    auto url = [NSBundle.mainBundle URLForResource:name withExtension:@"pdf"];
    auto * image = [[NSImage alloc] initWithContentsOfURL:url];
    _text.image = image;
}

@end
