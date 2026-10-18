// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_PCH_HPP_INCLUDED
#define TRANSLIT_HEADER_PCH_HPP_INCLUDED

#include <objc-helpers/NSStringUtil.h>
#include <objc-helpers/BlockUtil.h>

#include <intrusive_shared_ptr/apple_cf_ptr.h>

#include <memory>
#include <array>
#include <vector>
#include <string>
#include <map>
#include <ranges>
#include <span>
#include <algorithm>
#include <utility>
#include <type_traits>
#include <concepts>
#include <climits>
#include <stdexcept>

#include <signal.h>
#include <stdio.h>

#include <spawn.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import <WebKit/WebKit.h>
#endif

#import <os/log.h>

#ifndef NDEBUG
    #define os_log_debug_only(log, format, ...) os_log_debug(log, format __VA_OPT__(,) __VA_ARGS__)
#else
    #define os_log_debug_only(log, format, ...)
#endif

#endif

