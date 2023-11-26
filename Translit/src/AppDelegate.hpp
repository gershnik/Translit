// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_APP_DELEGATE_HPP_INCLUDED
#define TRANSLIT_HEADER_APP_DELEGATE_HPP_INCLUDED


@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> 

@property (nonatomic, readonly) NSMenu * menu;

@end

#endif


