// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_PCH_HPP_INCLUDED
#define TRANSLIT_HEADER_PCH_HPP_INCLUDED

#include <sys_string/sys_string.h>

#include <memory>
#include <vector>
#include <string>
#include <map>
#include <ranges>
#include <utility>

#include <signal.h>
#include <stdio.h>

#include <spawn.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import <WebKit/WebKit.h>
#endif

#import <os/log.h>

using namespace sysstr;

#endif

