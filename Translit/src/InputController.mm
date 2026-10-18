// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "Transliterator.hpp"
#include "Languages.hpp"
#include "AppDelegate.hpp"
#include "MenuProtocol.hpp"
#include "InputControllerProtocol.hpp"

class Compositor {
private:
    using String = std::basic_string<char16_t>;
    using StringView = std::basic_string_view<char16_t>;
public:
    void init() {
        clear();
        m_inputSource.reset();
        m_keyboardLayout = nullptr;
        
        m_inputSource = isptr::cf_attach(TISCopyCurrentKeyboardLayoutInputSource());
        if (!m_inputSource)
            return;
        auto data = (CFDataRef)TISGetInputSourceProperty(m_inputSource.get(), kTISPropertyUnicodeKeyLayoutData);
        if (!data) {
            m_inputSource.reset();
            return;
        }
        m_keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(data);
        m_keyboardType = LMGetKbdType();
    }
    
    void addKey(const NSStringCharAccess & str, UInt16 keyCode, NSUInteger flags) {
        if (!m_keyboardLayout) {
            m_value.append(str.begin(), str.end());
            m_completedSize = m_value.size();
            m_deadKeyState = 0;
            m_didCompose = false;
            return;
        }
        
        bool wasDead = m_deadKeyState != 0;
        
        UInt32 mods = 0;
        if (flags & NSEventModifierFlagShift)    mods |= shiftKey;
        if (flags & NSEventModifierFlagOption)   mods |= optionKey;
        if (flags & NSEventModifierFlagCapsLock) mods |= alphaLock;

        UniChar buf[16];
        UniCharCount len = 0;
        OSStatus err = UCKeyTranslate(m_keyboardLayout, keyCode, kUCKeyActionDown, (mods >> 8) & 0xFF,
                                      m_keyboardType, 0, &m_deadKeyState,
                                      std::size(buf), &len, buf);
        os_log_debug_only(OS_LOG_DEFAULT, "UCKeyTranslate: %d %ld %d %d",
                          err, len, m_deadKeyState, int(wasDead));
        if (err != noErr) {
            m_value.resize(m_completedSize);
            m_value.append(str.begin(), str.end());
            m_completedSize = m_value.size();
            m_deadKeyState = 0;
            return;
        }
        
        if (UInt16(m_deadKeyState) != 0) {
            //we processed a dead key
            if (wasDead && len != 0) {
                //previous dead key terminated (buf has its terminator), new one pending
                m_value.resize(m_completedSize);
                m_value.append(buf, buf + len);
                m_completedSize = m_value.size();
            }
            m_value.append(str.begin(), str.end());
            return;
        }
        m_value.resize(m_completedSize);
        if (wasDead)
            m_didCompose = true;
        m_value.append(buf, buf + len);
        m_completedSize = m_value.size();
        m_deadKeyState = 0;
    }
    
    auto done() const -> bool
        { return m_deadKeyState == 0; }
    
    auto result() const -> StringView
        { return m_value; }
    
    auto completedSize() const -> size_t
        { return m_completedSize; }
    
    auto didCompose() -> bool
        { return m_didCompose;}
    
    void clear() {
        m_value.clear();
        m_completedSize = 0;
        m_didCompose = false;
        m_deadKeyState = 0;
    }
    
    void clearCompleted() {
        m_value.erase(m_value.begin(), m_value.begin() + m_completedSize);
        m_completedSize = 0;
    }
private:
    isptr::cf_ptr<TISInputSourceRef> m_inputSource;
    const UCKeyboardLayout * m_keyboardLayout = nullptr;
    UInt8 m_keyboardType = 0;
    UInt32 m_deadKeyState = 0;
    String m_value;
    size_t m_completedSize = 0;
    bool m_didCompose = false;
};


@interface InputController : IMKInputController<MenuProtocol, InputControllerProtocol>

@end


@interface InputController() {
    Compositor _compositor;
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
        _transliterator = std::make_unique<Transliterator>();
        _compositor.init();
    }
    
    return self;
}

//IMKServerInput


-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {
    os_log_debug_only(OS_LOG_DEFAULT, "Receiving: '%{public}@', %ld, %lx",
                      string, keyCode, flags);
    
    auto isCommandKey = [&](const NSStringCharAccess & access) {
        if (access.size() != 1)
            return false;
        auto c = access[0];
        return c < 0x20 || c == 0x7F || (c >= 0xF700 && c <= 0xF8FF);
    };
    
    NSStringCharAccess access(string);
    if ((flags & (NSEventModifierFlagCommand | NSEventModifierFlagControl)) || isCommandKey(access)) {
        [self commitAllToSender:sender];
        return NO;
    }
    _compositor.addKey(access, keyCode, flags);
    return [self commitPartialToSender:sender];
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

-(void) displayAbout:(id)sender {
    auto del = (AppDelegate *)NSApp.delegate;
    [del displayAbout];
}

//InputControllerProtocol

- (NSString *) currentLanguage {
    return _currentLanguage;
}

-(void) changeVariant:(NSString *)variant {
    [self resetLanguage:_currentLanguage variant:variant];
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
            auto language = [val stringByReplacingOccurrencesOfString:prefix withString:@""
                                                              options:NSAnchoredSearch range:{0, val.length}];
            
            auto del = (AppDelegate *)NSApp.delegate;
            auto variant = [del getVariantForLanguage:language];
            [self resetLanguage:language variant:variant];
            [del setMappingsLanguage:_currentLanguage];
        }
    }
    [super setValue:value forTag:tag client:sender];
}

-(void) hidePalettes {
    auto del = (AppDelegate *)NSApp.delegate;
    [del deactivateUI];
    [super hidePalettes];
}

//Private

-(void) resetLanguage:(NSString *)language variant:(NSString *)variant {
    _currentLanguage = language;
    os_log_info(OS_LOG_DEFAULT, "Setting language to %{public}@, variant '%{public}@'", _currentLanguage, variant);
    _compositor.init();
    auto mapper = getMapperFor(language, variant);
    _transliterator = std::make_unique<Transliterator>(mapper);
}

-(void) commitAllToSender:(id<IMKTextInput>)sender {
    
    if (auto all = _transliterator->result(); !all.empty()) {
        auto text = makeNSString(all);
        os_log_debug_only(OS_LOG_DEFAULT, "Sending forced transliteration: %{public}@", text);
        [sender insertText:text replacementRange:NSRange{NSNotFound, NSNotFound}];
        _transliterator->clear();
    }
    if (auto all = _compositor.result(); !all.empty()) {
        auto text = makeNSString(all);
        os_log_debug_only(OS_LOG_DEFAULT, "Sending forced composition: %{public}@", text);
        [sender insertText:text replacementRange:NSRange{NSNotFound, NSNotFound}];
        _compositor.clear();
    }
}

-(BOOL) dispatchToTransliterator:(id<IMKTextInput>)sender input:(std::basic_string_view<char16_t>)input didCompose:(bool)didCompose {
    
    _transliterator->append(input);
    
    if (!_transliterator->matchedSomething()) {
        os_log_debug_only(OS_LOG_DEFAULT, "No transliteration");
        _transliterator->clear();
        if (didCompose) {
            auto text = makeNSString(input);
            [sender insertText:text replacementRange:NSRange{NSNotFound, NSNotFound}];
            return YES;
        }
        return NO;
    }
    
    //one of the conditions below must be true if we matched something
    assert(!_transliterator->result().empty());
    
    if (auto completedSize = _transliterator->completedSize()) {
        auto text = makeNSString(_transliterator->result().substr(0, completedSize));
        os_log_debug_only(OS_LOG_DEFAULT, "Sending completed: '%{public}@'", text);
        [sender insertText:text replacementRange:NSRange{NSNotFound, NSNotFound}];
        _transliterator->clearCompleted();
    }
    //at this point the only remaining thing in impl is incomplete tail
    if (auto incomplete = _transliterator->result(); !incomplete.empty()) {
        auto text = makeNSString(incomplete);
        os_log_debug_only(OS_LOG_DEFAULT, "Sending incomplete: '%{public}@'", text);
        auto attr = [self markForStyle:kTSMHiliteSelectedRawText atRange:{0, text.length}];
        auto attributed = [[NSMutableAttributedString alloc] initWithString:text attributes:attr];
        [sender setMarkedText:attributed
               selectionRange:{0, text.length}
             replacementRange:{NSNotFound, NSNotFound}];
    }
    return YES;
}


-(BOOL) commitPartialToSender:(id<IMKTextInput>)sender {
    
    if (!_compositor.done()) {
        os_log_debug_only(OS_LOG_DEFAULT, "Dead key");
        if (auto completedSize = _compositor.completedSize(); completedSize) {
            auto completed = _compositor.result().substr(0, completedSize);
            os_log_debug_only(OS_LOG_DEFAULT, "Dispatching completed composition: '%{public}@'", makeNSString(completed));
            bool res = [self dispatchToTransliterator:sender input:completed didCompose:true];
            assert(res); //we set didCompose to true, it means dispatchToTransliterator must send
            _compositor.clearCompleted();
        }
        std::basic_string<char16_t> composition;
        composition.append(_transliterator->result());
        composition.append(_compositor.result());
        if (!composition.empty()) {
            auto text = makeNSString(composition);
            os_log_debug_only(OS_LOG_DEFAULT, "Sending composition: '%{public}@'", text);
            auto attr = [self markForStyle:kTSMHiliteSelectedRawText atRange:{0, text.length}];
            auto attributed = [[NSMutableAttributedString alloc] initWithString:text attributes:attr];
            [sender setMarkedText:attributed
                   selectionRange:{0, text.length}
                 replacementRange:{NSNotFound, NSNotFound}];
            return YES;
        }
        return NO;
    }
    
    os_log_debug_only(OS_LOG_DEFAULT, "Composed: '%{public}@'", makeNSString(_compositor.result()));
    auto didCompose = _compositor.didCompose();
    auto ret = [self dispatchToTransliterator:sender input:_compositor.result() didCompose:didCompose];
    _compositor.clear();
    return ret;
}

@end

