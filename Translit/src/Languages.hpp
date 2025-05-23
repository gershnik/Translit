// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_LANGUAGES_HPP_INCLUDED
#define TRANSLIT_HEADER_LANGUAGES_HPP_INCLUDED


#include "Transliterator.hpp"

struct LanguageVariant {
    NSString * name;
    NSString * displayName;
    Transliterator::MappingFunc * mapper;
};

auto getVariantsForLanguage(NSString * name) -> std::span<const LanguageVariant>;
auto getMapperFor(NSString * language, NSString * variant) -> Transliterator::MappingFunc *;

#endif


