// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_MAPPINGS_WINDOW_CONTROLLER_HPP_INCLUDED
#define TRANSLIT_HEADER_MAPPINGS_WINDOW_CONTROLLER_HPP_INCLUDED

NS_ASSUME_NONNULL_BEGIN

@interface MappingsWindowController : NSWindowController

- (void) showLanguage:(NSString *)language;

@end

NS_ASSUME_NONNULL_END

#endif
