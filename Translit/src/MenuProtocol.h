// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_MENU_PROTOCOL_H_INCLUDED
#define TRANSLIT_HEADER_MENU_PROTOCOL_H_INCLUDED

@protocol MenuProtocol

-(void) showPreferences:(id)sender;
-(void) displayMappings:(id)sender;

@end

#endif

