// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_LANGUAGES_HPP_INCLUDED
#define TRANSLIT_HEADER_LANGUAGES_HPP_INCLUDED


#include "Transliterator.hpp"

struct LanguageVariant {
    NSString * name;
    NSString * displayName;
    Transliterator::MappingFunc * mapper;
    std::span<const uint8_t> mappings_html;
};

auto getVariantsForLanguage(NSString * name) -> std::span<const LanguageVariant>;

inline auto getMapperFor(NSString * language, NSString * variant) -> Transliterator::MappingFunc * {
    
    auto variants = getVariantsForLanguage(language);
    if (!variant)
        variant = @"";
    for (auto & current: variants) {
        if ([current.name isEqualToString:variant])
            return current.mapper;
    }
    return variants[0].mapper;
}

inline auto getHtmlFor(NSString * language, NSString * variant) -> std::span<const uint8_t> {
    
    auto variants = getVariantsForLanguage(language);
    if (!variant)
        variant = @"";
    for (auto & current: variants) {
        if ([current.name isEqualToString:variant])
            return current.mappings_html;
    }
    return variants[0].mappings_html;
}

#endif


