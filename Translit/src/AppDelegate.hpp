// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_APP_DELEGATE_HPP_INCLUDED
#define TRANSLIT_HEADER_APP_DELEGATE_HPP_INCLUDED


@protocol InputControllerProtocol;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> 

@property (nonatomic, readonly) NSMenu * menu;

-(void) setCurrentInputController:(id<InputControllerProtocol>)controller;
-(void) setCurrentAboutController:(NSWindowController *)controller;

-(void) displayMappingsForLanguage:(NSString *)language;
-(void) setMappingsLanguage:(NSString *)language;
-(NSString *) getVariantForLanguage:(NSString *)language;
-(void) setVariant:(NSString *)variant forLanguage:(NSString *)language;
-(void) deactivateUI;

@end

#endif


