// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TABLE_RU_HPP_INCLUDED
#define TRANSLIT_HEADER_TABLE_RU_HPP_INCLUDED

#include "Mapper.hpp"

template<std::ranges::forward_range Range>
constexpr auto g_mapperRuDefault = makePrefixMapper<Range,
    Mapping{u'А', u"A"},  //1
    Mapping{u'а', u"a"},
    Mapping{u'Б', u"B"},  //2
    Mapping{u'б', u"b"},
    Mapping{u'В', u"V"},  //3
    Mapping{u'в', u"v"},
    Mapping{u'Г', u"G"},  //4
    Mapping{u'г', u"g"},
    Mapping{u'Д', u"D"},  //5
    Mapping{u'д', u"d"},
    Mapping{u'Е', u"E"},  //6
    Mapping{u'е', u"e"},
    Mapping{u'Ё', u"Ë"},  //7
    Mapping{u'Ё', u"Ö"},
    Mapping{u'Ё', u"JO"},
    Mapping{u'Ё', u"Jo"},
    Mapping{u'Ё', u"YO"},
    Mapping{u'Ё', u"Yo"},
    Mapping{u'ё', u"ë"},
    Mapping{u'ё', u"ö"},
    Mapping{u'ё', u"jo"},
    Mapping{u'ё', u"yo"},
    Mapping{u'Ж', u"ZH"}, //8
    Mapping{u'Ж', u"Zh"},
    Mapping{u'ж', u"zh"},
    Mapping{u'З', u"Z"},  //9
    Mapping{u'з', u"z"},
    Mapping{u'И', u"I"},  //10
    Mapping{u'и', u"i"},
    Mapping{u'Й', u"J"},  //11
    Mapping{u'й', u"j"},
    Mapping{u'К', u"K"},  //12
    Mapping{u'к', u"k"},
    Mapping{u'Л', u"L"},  //13
    Mapping{u'л', u"l"},
    Mapping{u'М', u"M"},  //14
    Mapping{u'м', u"m"},
    Mapping{u'Н', u"N"},  //15
    Mapping{u'н', u"n"},
    Mapping{u'О', u"O"},  //16
    Mapping{u'о', u"o"},
    Mapping{u'П', u"P"},  //17
    Mapping{u'п', u"p"},
    Mapping{u'Р', u"R"},  //18
    Mapping{u'р', u"r"},
    Mapping{u'С', u"S"},  //19
    Mapping{u'с', u"s"},
    Mapping{u'Т', u"T"},  //20
    Mapping{u'т', u"t"},
    Mapping{u'У', u"U"},  //21
    Mapping{u'у', u"u"},
    Mapping{u'Ф', u"F"},  //22
    Mapping{u'ф', u"f"},
    Mapping{u'Х', u"H"},  //23
    Mapping{u'Х', u"X"},
    Mapping{u'х', u"h"},
    Mapping{u'х', u"x"},
    Mapping{u'Ц', u"C"},  //24
    Mapping{u'ц', u"c"},
    Mapping{u'Ч', u"CH"}, //25
    Mapping{u'Ч', u"Ch"},
    Mapping{u'ч', u"ch"},
    Mapping{u'Ш', u"SH"}, //26
    Mapping{u'Ш', u"Sh"},
    Mapping{u'ш', u"sh"},
    Mapping{u'Щ', u"W"},  //27
    Mapping{u'Щ', u"SHH"},
    Mapping{u'Щ', u"SHh"},
    Mapping{u'Щ', u"Shh"},
    Mapping{u'щ', u"w"},
    Mapping{u'щ', u"shh"},
    Mapping{u'Ъ', u"QQ"}, //28
    Mapping{u'ъ', u"qq"},
    Mapping{u'Ы', u"Y"},  //29
    Mapping{u'ы', u"y"},
    Mapping{u'Ь', u"Q"},  //30
    Mapping{u'ь', u"q"},
    Mapping{u'Э', u"Ä"},  //31
    Mapping{u'Э', u"JE"},
    Mapping{u'Э', u"Je"},
    Mapping{u'э', u"je"},
    Mapping{u'э', u"ä"},
    Mapping{u'Ю', u"Ü"},  //32
    Mapping{u'Ю', u"JU"},
    Mapping{u'Ю', u"Ju"},
    Mapping{u'Ю', u"YU"},
    Mapping{u'Ю', u"Yu"},
    Mapping{u'ю', u"ü"},
    Mapping{u'ю', u"ju"},
    Mapping{u'ю', u"yu"},
    Mapping{u'Я', u"JA"}, //33
    Mapping{u'Я', u"Ja"},
    Mapping{u'Я', u"YA"},
    Mapping{u'Я', u"Ya"},
    Mapping{u'я', u"ja"},
    Mapping{u'я', u"ya"}
>();

template<std::ranges::forward_range Range>
constexpr auto g_mapperRuTranslitRu = makePrefixMapper<Range,
    Mapping{u'А', u"A"},  //1
    Mapping{u'а', u"a"},
    Mapping{u'Б', u"B"},  //2
    Mapping{u'б', u"b"},
    Mapping{u'В', u"V"},  //3
    Mapping{u'в', u"v"},
    Mapping{u'Г', u"G"},  //4
    Mapping{u'г', u"g"},
    Mapping{u'Д', u"D"},  //5
    Mapping{u'д', u"d"},
    Mapping{u'Е', u"E"},  //6
    Mapping{u'е', u"e"},
    Mapping{u'Ё', u"Ë"},  //7
    Mapping{u'Ё', u"Ö"},
    Mapping{u'Ё', u"JO"},
    Mapping{u'Ё', u"Jo"},
    Mapping{u'Ё', u"YO"},
    Mapping{u'Ё', u"Yo"},
    Mapping{u'ё', u"ë"},
    Mapping{u'ё', u"ö"},
    Mapping{u'ё', u"jo"},
    Mapping{u'ё', u"yo"},
    Mapping{u'Ж', u"ZH"}, //8
    Mapping{u'Ж', u"Zh"},
    Mapping{u'ж', u"zh"},
    Mapping{u'З', u"Z"},  //9
    Mapping{u'з', u"z"},
    Mapping{u'И', u"I"},  //10
    Mapping{u'и', u"i"},
    Mapping{u'Й', u"J"},  //11
    Mapping{u'й', u"j"},
    Mapping{u'К', u"K"},  //12
    Mapping{u'к', u"k"},
    Mapping{u'Л', u"L"},  //13
    Mapping{u'л', u"l"},
    Mapping{u'М', u"M"},  //14
    Mapping{u'м', u"m"},
    Mapping{u'Н', u"N"},  //15
    Mapping{u'н', u"n"},
    Mapping{u'О', u"O"},  //16
    Mapping{u'о', u"o"},
    Mapping{u'П', u"P"},  //17
    Mapping{u'п', u"p"},
    Mapping{u'Р', u"R"},  //18
    Mapping{u'р', u"r"},
    Mapping{u'С', u"S"},  //19
    Mapping{u'с', u"s"},
    Mapping{u'Т', u"T"},  //20
    Mapping{u'т', u"t"},
    Mapping{u'У', u"U"},  //21
    Mapping{u'у', u"u"},
    Mapping{u'Ф', u"F"},  //22
    Mapping{u'ф', u"f"},
    Mapping{u'Х', u"H"},  //23
    Mapping{u'Х', u"X"},
    Mapping{u'х', u"h"},
    Mapping{u'х', u"x"},
    Mapping{u'Ц', u"C"},  //24
    Mapping{u'ц', u"c"},
    Mapping{u'Ч', u"CH"}, //25
    Mapping{u'Ч', u"Ch"},
    Mapping{u'ч', u"ch"},
    Mapping{u'Ш', u"SH"}, //26
    Mapping{u'Ш', u"Sh"},
    Mapping{u'ш', u"sh"},
    Mapping{u'Щ', u"W"},  //27
    Mapping{u'Щ', u"SHH"},
    Mapping{u'Щ', u"SHh"},
    Mapping{u'Щ', u"Shh"},
    Mapping{u'щ', u"w"},
    Mapping{u'щ', u"shh"},
    Mapping{u'Ъ', u"##"}, //28
    Mapping{u'ъ', u"#"},
    Mapping{u'ъ', u"tvz"},
    Mapping{u'Ы', u"Y"},  //29
    Mapping{u'ы', u"y"},
    Mapping{u'Ь', u"''"},  //30
    Mapping{u'ь', u"'"},
    Mapping{u'ь', u"mjz"},
    Mapping{u'Э', u"Ä"},  //31
    Mapping{u'Э', u"JE"},
    Mapping{u'Э', u"Je"},
    Mapping{u'э', u"ä"},
    Mapping{u'э', u"je"},
    Mapping{u'Ю', u"Ü"},  //32
    Mapping{u'Ю', u"JU"},
    Mapping{u'Ю', u"Ju"},
    Mapping{u'Ю', u"YU"},
    Mapping{u'Ю', u"Yu"},
    Mapping{u'ю', u"ü"},
    Mapping{u'ю', u"ju"},
    Mapping{u'ю', u"yu"},
    Mapping{u'Я', u"JA"}, //33
    Mapping{u'Я', u"Ja"},
    Mapping{u'Я', u"YA"},
    Mapping{u'Я', u"Ya"},
    Mapping{u'Я', u"Q"},
    Mapping{u'я', u"ja"},
    Mapping{u'я', u"ya"},
    Mapping{u'я', u"q"}
>();

#endif
