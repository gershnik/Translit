// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TABLE_HE_HPP_INCLUDED
#define TRANSLIT_HEADER_TABLE_HE_HPP_INCLUDED

#include "Mapper.hpp"

template<std::ranges::forward_range Range>
constexpr auto g_mapperHe = makePrefixMapper<Range,
    Mapping{u'א', u"a"},
    Mapping{u'ב', u"b"},
    Mapping{u'ב', u"v"},
    Mapping{u'ג', u"g"},
    Mapping{u'ד', u"d"},
    Mapping{u'ה', u"h"},
    Mapping{u'ו', u"o"},
    Mapping{u'ו', u"u"},
    Mapping{u'ז', u"z"},
    Mapping{u'ח', u"x"},
    Mapping{u'ט', u"T"},
    Mapping{u'י', u"i"},
    Mapping{u'י', u"j"},
    Mapping{u'כ', u"k"},
    Mapping{u'ך', u"K"},
    Mapping{u'ל', u"l"},
    Mapping{u'מ', u"m"},
    Mapping{u'ם', u"M"},
    Mapping{u'נ', u"n"},
    Mapping{u'ן', u"N"},
    Mapping{u'ס', u"s"},
    Mapping{u'ע', u"y"},
    Mapping{u'פ', u"f"},
    Mapping{u'פ', u"p"},
    Mapping{u'ף', u"F"},
    Mapping{u'ף', u"P"},
    Mapping{u'צ', u"c"},
    Mapping{u'ץ', u"C"},
    Mapping{u'ק', u"q"},
    Mapping{u'ר', u"r"},
    Mapping{u'ש', u"w"},
    Mapping{u'ת', u"t"},
    Mapping{u'ְ', u"E"},
    Mapping{u'ֵ', u"EE"},
    Mapping{u'ֶ', u"EEE"},
    Mapping{u'ֱ', u"EEEE"},
    Mapping{u'ַ', u"EA"},
    Mapping{u'ָ', u"EAA"},
    Mapping{u'ֲ', u"EAE"},
    Mapping{u'ֳ', u"EAAE"},
    Mapping{u'ִ', u"EI"},
    Mapping{u'ֹ', u"EO"},
    Mapping{u'ֻ', u"EU"},
    Mapping{u'ּ', u"ED"},
    Mapping{u'ׂ', u"ES"},
    Mapping{u'ׁ', u"EW"},
    Mapping{u'׳', u"G"},
    Mapping{u'״', u"GG"}
>();

#endif
