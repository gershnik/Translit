// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TABLE_UK_HPP_INCLUDED
#define TRANSLIT_HEADER_TABLE_UK_HPP_INCLUDED

#include "Mapper.hpp"

template<std::ranges::forward_range Range>
constexpr auto g_mapperUkDefault = makePrefixMapper<Range,
    Mapping{u'А', u"A"},  //1
    Mapping{u'а', u"a"},
    Mapping{u'Б', u"B"},  //2
    Mapping{u'б', u"b"},
    Mapping{u'В', u"V"},  //3
    Mapping{u'в', u"v"},
    Mapping{u'Г', u"G"},  //4
    Mapping{u'г', u"g"},
    Mapping{u'Ґ', u"GG"}, //5
    Mapping{u'ґ', u"gg"},
    Mapping{u'Д', u"D"},  //6
    Mapping{u'д', u"d"},
    Mapping{u'Е', u"E"},  //7
    Mapping{u'е', u"e"},
    Mapping{u'Є', u"JE"}, //8
    Mapping{u'Є', u"Je"},
    Mapping{u'Є', u"YE"},
    Mapping{u'Є', u"Ye"},
    Mapping{u'є', u"je"},
    Mapping{u'є', u"ye"},
    Mapping{u'Ж', u"ZH"}, //9
    Mapping{u'Ж', u"Zh"},
    Mapping{u'ж', u"zh"},
    Mapping{u'З', u"Z"},  //10
    Mapping{u'з', u"z"},
    Mapping{u'И', u"Y"},  //11
    Mapping{u'и', u"y"},
    Mapping{u'І', u"I"},  //12
    Mapping{u'і', u"i"},
    Mapping{u'Ї', u"JI"}, //13
    Mapping{u'Ї', u"Ji"},
    Mapping{u'ї', u"ji"},
    Mapping{u'Й', u"J"},  //14
    Mapping{u'й', u"j"},
    Mapping{u'К', u"K"},  //15
    Mapping{u'к', u"k"},
    Mapping{u'Л', u"L"},  //16
    Mapping{u'л', u"l"},
    Mapping{u'М', u"M"},  //17
    Mapping{u'м', u"m"},
    Mapping{u'Н', u"N"},  //18
    Mapping{u'н', u"n"},
    Mapping{u'О', u"O"},  //19
    Mapping{u'о', u"o"},
    Mapping{u'П', u"P"},  //20
    Mapping{u'п', u"p"},
    Mapping{u'Р', u"R"},  //21
    Mapping{u'р', u"r"},
    Mapping{u'С', u"S"},  //22
    Mapping{u'с', u"s"},
    Mapping{u'Т', u"T"},  //23
    Mapping{u'т', u"t"},
    Mapping{u'У', u"U"},  //24
    Mapping{u'у', u"u"},
    Mapping{u'Ф', u"F"},  //25
    Mapping{u'ф', u"f"},
    Mapping{u'Х', u"H"},  //26
    Mapping{u'Х', u"X"},
    Mapping{u'х', u"h"},
    Mapping{u'х', u"x"},
    Mapping{u'Ц', u"C"},  //27
    Mapping{u'ц', u"c"},
    Mapping{u'Ч', u"CH"}, //28
    Mapping{u'Ч', u"Ch"},
    Mapping{u'ч', u"ch"},
    Mapping{u'Ш', u"SH"}, //29
    Mapping{u'Ш', u"Sh"},
    Mapping{u'ш', u"sh"},
    Mapping{u'Щ', u"W"},  //30
    Mapping{u'Щ', u"SHH"},
    Mapping{u'Щ', u"SHh"},
    Mapping{u'Щ', u"Shh"},
    Mapping{u'щ', u"w"},
    Mapping{u'щ', u"shh"},
    Mapping{u'Ь', u"Q"},  //31
    Mapping{u'ь', u"q"},
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
constexpr auto g_mapperUkTranslitRu = makePrefixMapper<Range,
    Mapping{u'А', u"A"},  //1
    Mapping{u'а', u"a"},
    Mapping{u'Б', u"B"},  //2
    Mapping{u'б', u"b"},
    Mapping{u'В', u"V"},  //3
    Mapping{u'в', u"v"},
    Mapping{u'Г', u"G"},  //4
    Mapping{u'г', u"g"},
    Mapping{u'Ґ', u"G'"}, //5
    Mapping{u'ґ', u"g'"},
    Mapping{u'Д', u"D"},  //6
    Mapping{u'д', u"d"},
    Mapping{u'Е', u"E"},  //7
    Mapping{u'е', u"e"},
    Mapping{u'Є', u"JE"}, //8
    Mapping{u'Є', u"Je"},
    Mapping{u'Є', u"YE"},
    Mapping{u'Є', u"Ye"},
    Mapping{u'є', u"je"},
    Mapping{u'є', u"ye"},
    Mapping{u'Ж', u"ZH"}, //9
    Mapping{u'Ж', u"Zh"},
    Mapping{u'ж', u"zh"},
    Mapping{u'З', u"Z"},  //10
    Mapping{u'з', u"z"},
    Mapping{u'И', u"Y"},  //11
    Mapping{u'и', u"y"},
    Mapping{u'І', u"I"},  //12
    Mapping{u'і', u"i"},
    Mapping{u'Ї', u"I'"}, //13
    Mapping{u'Ї', u"JI"},
    Mapping{u'Ї', u"Ji"},
    Mapping{u'ї', u"i'"},
    Mapping{u'ї', u"ji"},
    Mapping{u'Й', u"J"},  //14
    Mapping{u'й', u"j"},
    Mapping{u'К', u"K"},  //15
    Mapping{u'к', u"k"},
    Mapping{u'Л', u"L"},  //16
    Mapping{u'л', u"l"},
    Mapping{u'М', u"M"},  //17
    Mapping{u'м', u"m"},
    Mapping{u'Н', u"N"},  //18
    Mapping{u'н', u"n"},
    Mapping{u'О', u"O"},  //19
    Mapping{u'о', u"o"},
    Mapping{u'П', u"P"},  //20
    Mapping{u'п', u"p"},
    Mapping{u'Р', u"R"},  //21
    Mapping{u'р', u"r"},
    Mapping{u'С', u"S"},  //22
    Mapping{u'с', u"s"},
    Mapping{u'Т', u"T"},  //23
    Mapping{u'т', u"t"},
    Mapping{u'У', u"U"},  //24
    Mapping{u'у', u"u"},
    Mapping{u'Ф', u"F"},  //25
    Mapping{u'ф', u"f"},
    Mapping{u'Х', u"H"},  //26
    Mapping{u'Х', u"X"},
    Mapping{u'х', u"h"},
    Mapping{u'х', u"x"},
    Mapping{u'Ц', u"C"},  //27
    Mapping{u'ц', u"c"},
    Mapping{u'Ч', u"CH"}, //28
    Mapping{u'Ч', u"Ch"},
    Mapping{u'ч', u"ch"},
    Mapping{u'Ш', u"W"},  //29
    Mapping{u'Ш', u"SH"},
    Mapping{u'Ш', u"Sh"},
    Mapping{u'ш', u"w"},
    Mapping{u'ш', u"sh"},
    Mapping{u'Щ', u"Q"},  //30
    Mapping{u'Щ', u"SHH"},
    Mapping{u'Щ', u"SHh"},
    Mapping{u'Щ', u"Shh"},
    Mapping{u'щ', u"q"},
    Mapping{u'щ', u"shh"},
    Mapping{u'Ь', u"''"}, //31
    Mapping{u'ь', u"'"},
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

#endif
