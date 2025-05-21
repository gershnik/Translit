// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_INPUT_CONTROLLER_PROTOCOL_HPP_INCLUDED
#define TRANSLIT_HEADER_INPUT_CONTROLLER_PROTOCOL_HPP_INCLUDED

@protocol InputControllerProtocol

@property (nonatomic, readonly) NSString * currentLanguage;

-(void) changeVariant:(NSString *)variant;

@end

#endif
