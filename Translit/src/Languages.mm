// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later
             
// THIS FILE IS AUTO-GENERATED. DO NOT EDIT.

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

static const LanguageVariant g_ruEntries[] = {
    { @"", @"default", g_mapperRuDefault<Range> },
    { @"translit-ru", @"translit.ru", g_mapperRuTranslitRu<Range> },
};
static constexpr std::span<const LanguageVariant> g_ru{g_ruEntries};

static const LanguageVariant g_ukEntries[] = {
    { @"", @"default", g_mapperUkDefault<Range> },
    { @"translit-ru", @"translit.net", g_mapperUkTranslitRu<Range> },
};
static constexpr std::span<const LanguageVariant> g_uk{g_ukEntries};

static const LanguageVariant g_beEntries[] = {
    { @"", @"default", g_mapperBeDefault<Range> },
    { @"translit-ru", @"translit.net", g_mapperBeTranslitRu<Range> },
};
static constexpr std::span<const LanguageVariant> g_be{g_beEntries};

static const LanguageVariant g_heEntries[] = {
    { @"", @"default", g_mapperHeDefault<Range> },
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
