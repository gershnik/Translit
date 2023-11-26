// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "Transliterator.hpp"
#include "TransliteratorRegistry.hpp"
#include "AppDelegate.hpp"
#include "MenuProtocol.hpp"
#include "MappingsWindowController.hpp"


@interface InputController : IMKInputController<MenuProtocol>

@end


@interface InputController() {
    Transliterator * _transliterator;
    MappingsWindowController * _mappingsController;
    NSString * _currentLanguage;
}

@end

@implementation InputController

-(id) initWithServer:(IMKServer*)server delegate:(id)delegate client:(id<IMKTextInput>)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    
    if (self)
    {
        _currentLanguage = @"ru";
        _transliterator = &getTransliterator(_currentLanguage);
        _transliterator->clear();
    }
    
    return self;
}

//IMKServerInput

-(BOOL) inputText:(NSString*)string client:(id<IMKTextInput>)sender {
    
#ifndef NDEBUG
    os_log_debug(OS_LOG_DEFAULT, "Receiving: '%{public}@'", string);
#endif
    _transliterator->append(string);
    return [self commitPartialToSender:sender];
}

-(BOOL) didCommandBySelector:(SEL)aSelector client:(id<IMKTextInput>)sender {
    [self commitAllToSender:sender];
    return NO;
}


-(void) commitComposition:(id<IMKTextInput>)sender {
    [self commitAllToSender:sender];
}

-(NSMenu*) menu
{
    auto del = (AppDelegate *)NSApp.delegate;
    return del.menu;
}


//-(void) showPreferences:(id)sender {
//    [super showPreferences:sender];
//}


//MenuProtocol

-(void) displayMappings:(id)sender {
    if (!_mappingsController)
        _mappingsController = [[MappingsWindowController alloc] initWithWindowNibName:@"mappings"];
    _mappingsController.language = _currentLanguage;
    [_mappingsController showWindow:self];
    [_mappingsController.window orderFrontRegardless];
}


//IMKStateSetting

-(id) valueForTag:(long)tag client:(id)sender {
    os_log_debug(OS_LOG_DEFAULT, "Get Value for tag %li", tag);
    return [super valueForTag:tag client:sender];
}

-(void) setValue:(id)value forTag:(long)tag client:(id)sender
{
    os_log_debug(OS_LOG_DEFAULT, "Set Value %{public}@ for tag %li", value, tag);
    constexpr long langTag = 1768778093; //kTSMDocumentInputModePropertyTag = 'imim' from TextServices.h
    
    switch(tag) {
        case langTag: {
            sys_string val(value);
            sys_string prefix = sys_string(NSBundle.mainBundle.bundleIdentifier) + S(".");
            _currentLanguage = val.remove_prefix(prefix).ns_str();
            os_log_info(OS_LOG_DEFAULT, "Setting language to %{public}@", _currentLanguage);
            _transliterator = &getTransliterator(_currentLanguage);
            _transliterator->clear();
            if (_mappingsController)
                _mappingsController.language = _currentLanguage;
        }
    }
    [super setValue:value forTag:tag client:sender];
}

//-(void) deactivateServer:(id)sender {
//    os_log_debug(OS_LOG_DEFAULT, "Deactivate");
//}

//Private

-(void) commitAllToSender:(id<IMKTextInput>)sender {
    
    if (auto all = _transliterator->result(); !all.empty()) {
        sys_string text(all);
#ifndef NDEBUG
        os_log_debug(OS_LOG_DEFAULT, "Sending completed: %{public}@", text.ns_str());
#endif
        [sender insertText:text.ns_str() replacementRange:NSRange{NSNotFound, NSNotFound}];
        _transliterator->clear();
    }
}

-(BOOL) commitPartialToSender:(id<IMKTextInput>)sender {
    
    if (!_transliterator->matchedSomething()) {
#ifndef NDEBUG
        os_log_debug(OS_LOG_DEFAULT, "Not sending");
#endif
        _transliterator->clear();
        return NO;
    }
    
    //one of the conditions below must be true if we matched something
    assert(!_transliterator->result().empty());
    
    if (auto completedSize = _transliterator->completedSize()) {
        sys_string text(_transliterator->result().data(), completedSize);
#ifndef NDEBUG
        os_log_debug(OS_LOG_DEFAULT, "Sending completed: '%{public}@'", text.ns_str());
#endif
        [sender insertText:text.ns_str() replacementRange:NSRange{NSNotFound, NSNotFound}];
        _transliterator->clearCompleted();
    }
    //at this point the only remaining thing in impl is incomplete tail
    if (auto incomplete = _transliterator->result(); !incomplete.empty()) {
        sys_string text(incomplete);
#ifndef NDEBUG
        os_log_debug(OS_LOG_DEFAULT, "Sending incomplete: '%{public}@'", text.ns_str());
#endif
        [sender setMarkedText:text.ns_str()
               selectionRange:NSRange{0, NSUInteger(text.storage_size())}
             replacementRange:NSRange{NSNotFound, NSNotFound}];
    }
    return YES;
}

@end

