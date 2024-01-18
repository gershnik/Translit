// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#import "MappingsWindowController.hpp"


@interface MappingsWindowController () {
    IBOutlet NSImageView * _text;
    NSString * _language;
}

@end

@implementation MappingsWindowController


-(void) windowDidLoad {
    [super windowDidLoad];
    [_text setWantsLayer:true];
    _text.layer.backgroundColor = NSColor.whiteColor.CGColor;
    [self setLanguage:_language];
}

-(NSString *) language {
    return _language;
}

-(void) setLanguage:(NSString *)language {
    _language = language;
    if (!_text)
        return;
    if (_language) {
        auto name = [@"mapping-" stringByAppendingString:_language];
        auto url = [NSBundle.mainBundle URLForResource:name withExtension:@"pdf"];
        auto * image = [[NSImage alloc] initWithContentsOfURL:url];
        _text.image = image;
    } else {
        _text.image = nil;
    }
}

@end
