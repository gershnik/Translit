// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "Languages.hpp"

#include "TableRU.hpp"
#include "TableUK.hpp"
#include "TableBE.hpp"
#include "TableHE.hpp"

using MappingFunc = Transliterator::MappingFunc;
using Range = Transliterator::Range;

static const LanguageVariant g_defaultEntries[] = {
    { @"",              @"default",         Transliterator::nullMapper },
};
static constexpr std::span<const LanguageVariant> g_default{g_defaultEntries};

static const LanguageVariant g_russianEntries[] = {
    { @"",              @"default",         static_cast<MappingFunc *>(g_mapperRuDefault<Range>) },
    { @"translit-ru",   @"translit.ru",     static_cast<MappingFunc *>(g_mapperRuTranslitRu<Range>) }
};
static constexpr std::span<const LanguageVariant> g_russian{g_russianEntries};

static const LanguageVariant g_ukrainianEntries[] = {
    { @"",              @"default",         static_cast<MappingFunc *>(g_mapperUkDefault<Range>) },
    { @"translit-ru",   @"translit.net",    static_cast<MappingFunc *>(g_mapperUkTranslitRu<Range>) }
};
static constexpr std::span<const LanguageVariant> g_ukrainian{g_ukrainianEntries};

static const LanguageVariant g_belarussianEntries[] = {
    { @"",              @"default",         static_cast<MappingFunc *>(g_mapperBeDefault<Range>) },
    { @"translit-ru",   @"translit.net",    static_cast<MappingFunc *>(g_mapperBeTranslitRu<Range>) }
};
static constexpr std::span<const LanguageVariant> g_belarussian{g_belarussianEntries};

static const LanguageVariant g_hebrewEntries[] = {
    { @"",              @"default",         static_cast<MappingFunc *>(g_mapperHe<Range>) },
};
static constexpr std::span<const LanguageVariant> g_hebrew{g_hebrewEntries};


auto getVariantsForLanguage(NSString * name) -> std::span<const LanguageVariant> {
    static constexpr auto mapper = makeMapper<NSStringCharAccess,
        //default
        &g_default,
        //mappings
        Mapping{&g_russian,     u"ru"},
        Mapping{&g_ukrainian,   u"uk"},
        Mapping{&g_belarussian, u"be"},
        Mapping{&g_hebrew,      u"he"}
    >();
    
    return *mapper(name);
}

auto getMapperFor(NSString * language, NSString * variant) -> MappingFunc * {
    
    auto variants = getVariantsForLanguage(language);
    if (!variant)
        variant = @"";
    for (auto & current: variants) {
        if ([current.name isEqualToString:variant])
            return current.mapper;
    }
    return variants[0].mapper;
}



