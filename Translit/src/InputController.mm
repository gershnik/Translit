// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "Transliterator.hpp"
#include "AppDelegate.hpp"
#include "MenuProtocol.hpp"



@interface InputController : IMKInputController<MenuProtocol>

@end


@interface InputController() {
    std::unique_ptr<Transliterator> _transliterator;
    NSString * _currentLanguage;
}

@end

@implementation InputController

-(id) initWithServer:(IMKServer*)server delegate:(id)delegate client:(id<IMKTextInput>)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    
    if (self)
    {
        _currentLanguage = @"ru";
        _transliterator = std::make_unique<Transliterator>(_currentLanguage);
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
    auto del = (AppDelegate *)NSApp.delegate;
    [del displayMappingsForLanguage:_currentLanguage];
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
            auto val = (NSString*)value;
            auto prefix = [NSBundle.mainBundle.bundleIdentifier stringByAppendingString:@"."];
            _currentLanguage = [val stringByReplacingOccurrencesOfString:prefix withString:@"" 
                                                                 options:NSAnchoredSearch range:{0, val.length}];
            os_log_info(OS_LOG_DEFAULT, "Setting language to %{public}@", _currentLanguage);
            _transliterator = std::make_unique<Transliterator>(_currentLanguage);
            auto del = (AppDelegate *)NSApp.delegate;
            [del setMappingsLanguage:_currentLanguage];
        }
    }
    [super setValue:value forTag:tag client:sender];
}

- (void)activateServer:(id)sender {
    [super activateServer:sender];
    
    auto del = (AppDelegate *)NSApp.delegate;
    [del setMappingsLanguage:_currentLanguage];
}

-(void) deactivateServer:(id)sender {
    auto del = (AppDelegate *)NSApp.delegate;
    [del setMappingsLanguage:nil];
    [super deactivateServer:sender];
}

//Private

-(void) commitAllToSender:(id<IMKTextInput>)sender {
    
    if (auto all = _transliterator->result(); !all.empty()) {
        auto text = makeNSString(all);
#ifndef NDEBUG
        os_log_debug(OS_LOG_DEFAULT, "Sending completed: %{public}@", text);
#endif
        [sender insertText:text replacementRange:NSRange{NSNotFound, NSNotFound}];
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
        auto text = makeNSString(_transliterator->result().substr(0, completedSize));
#ifndef NDEBUG
        os_log_debug(OS_LOG_DEFAULT, "Sending completed: '%{public}@'", text);
#endif
        [sender insertText:text replacementRange:NSRange{NSNotFound, NSNotFound}];
        _transliterator->clearCompleted();
    }
    //at this point the only remaining thing in impl is incomplete tail
    if (auto incomplete = _transliterator->result(); !incomplete.empty()) {
        auto text = makeNSString(incomplete);
#ifndef NDEBUG
        os_log_debug(OS_LOG_DEFAULT, "Sending incomplete: '%{public}@'", text);
#endif
        [sender setMarkedText:text
               selectionRange:{0, text.length}
             replacementRange:{NSNotFound, NSNotFound}];
    }
    return YES;
}

@end

