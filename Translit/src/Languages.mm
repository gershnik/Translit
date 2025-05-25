// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later
             
// THIS FILE IS AUTO-GENERATED. DO NOT EDIT.

#include "Languages.hpp"

#include "../tables/TableRU.hpp"
#include "../tables/TableUK.hpp"
#include "../tables/TableBE.hpp"
#include "../tables/TableHE.hpp"

using MappingFunc = Transliterator::MappingFunc;
using Range = Transliterator::Range;
              
#pragma clang diagnostic ignored "-Wc23-extensions"

static const LanguageVariant g_defaultEntries[] = {
    { @"",              @"default",         Transliterator::nullMapper, {} },
};
static constexpr std::span<const LanguageVariant> g_default{g_defaultEntries};

static const uint8_t g_htmlRuDefault[] = {
    #embed "../tables/mapping-ru.html"
};
static const uint8_t g_htmlRuTranslitRu[] = {
    #embed "../tables/mapping-ru.translit-ru.html"
};
static const LanguageVariant g_ruEntries[] = {
    { @"", @"default", g_mapperRuDefault<Range>, g_htmlRuDefault },
    { @"translit-ru", @"translit.ru", g_mapperRuTranslitRu<Range>, g_htmlRuTranslitRu },
};
static constexpr std::span<const LanguageVariant> g_ru{g_ruEntries};

static const uint8_t g_htmlUkDefault[] = {
    #embed "../tables/mapping-uk.html"
};
static const uint8_t g_htmlUkTranslitRu[] = {
    #embed "../tables/mapping-uk.translit-ru.html"
};
static const LanguageVariant g_ukEntries[] = {
    { @"", @"default", g_mapperUkDefault<Range>, g_htmlUkDefault },
    { @"translit-ru", @"translit.net", g_mapperUkTranslitRu<Range>, g_htmlUkTranslitRu },
};
static constexpr std::span<const LanguageVariant> g_uk{g_ukEntries};

static const uint8_t g_htmlBeDefault[] = {
    #embed "../tables/mapping-be.html"
};
static const uint8_t g_htmlBeTranslitRu[] = {
    #embed "../tables/mapping-be.translit-ru.html"
};
static const LanguageVariant g_beEntries[] = {
    { @"", @"default", g_mapperBeDefault<Range>, g_htmlBeDefault },
    { @"translit-ru", @"translit.net", g_mapperBeTranslitRu<Range>, g_htmlBeTranslitRu },
};
static constexpr std::span<const LanguageVariant> g_be{g_beEntries};

static const uint8_t g_htmlHeDefault[] = {
    #embed "../tables/mapping-he.html"
};
static const LanguageVariant g_heEntries[] = {
    { @"", @"default", g_mapperHeDefault<Range>, g_htmlHeDefault },
};
static constexpr std::span<const LanguageVariant> g_he{g_heEntries};

auto getVariantsForLanguage(NSString * name) -> std::span<const LanguageVariant> {
    static constexpr auto mapper = makeMapper<NSStringCharAccess,
        //default
        &g_default,
        //mappings
        Mapping{&g_ru,     u"ru"},
        Mapping{&g_uk,     u"uk"},
        Mapping{&g_be,     u"be"},
        Mapping{&g_he,     u"he"}
    >();
    
    return *mapper(name);
}
