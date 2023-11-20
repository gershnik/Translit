// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TABLE_RU_H_INCLUDED
#define TRANSLIT_HEADER_TABLE_RU_H_INCLUDED

constexpr std::pair<char16_t, const char16_t *> g_tableRu[] = {
    {u'А', u"A"},  //1
    {u'а', u"a"},
    {u'Б', u"B"},  //2
    {u'б', u"b"},
    {u'В', u"V"},  //3
    {u'в', u"v"},
    {u'Г', u"G"},  //4
    {u'г', u"g"},
    {u'Д', u"D"},  //5
    {u'д', u"d"},
    {u'Е', u"E"},  //6
    {u'е', u"e"},
    {u'Ё', u"Ë"},  //7
    {u'Ё', u"Ö"},
    {u'Ё', u"JO"},
    {u'Ё', u"Jo"},
    {u'Ё', u"YO"},
    {u'Ё', u"Yo"},
    {u'ё', u"ë"},
    {u'ё', u"ö"},
    {u'ё', u"jo"},
    {u'ё', u"yo"},
    {u'Ж', u"ZH"}, //8
    {u'Ж', u"Zh"},
    {u'ж', u"zh"},
    {u'З', u"Z"},  //9
    {u'з', u"z"},
    {u'И', u"I"},  //10
    {u'и', u"i"},
    {u'Й', u"J"},  //11
    {u'й', u"j"},
    {u'К', u"K"},  //12
    {u'к', u"k"},
    {u'Л', u"L"},  //13
    {u'л', u"l"},
    {u'М', u"M"},  //14
    {u'м', u"m"},
    {u'Н', u"N"},  //15
    {u'н', u"n"},
    {u'О', u"O"},  //16
    {u'о', u"o"},
    {u'П', u"P"},  //17
    {u'п', u"p"},
    {u'Р', u"R"},  //18
    {u'р', u"r"},
    {u'С', u"S"},  //19
    {u'с', u"s"},
    {u'Т', u"T"},  //20
    {u'т', u"t"},
    {u'У', u"U"},  //21
    {u'у', u"u"},
    {u'Ф', u"F"},  //22
    {u'ф', u"f"},
    {u'Х', u"H"},  //23
    {u'Х', u"X"},
    {u'х', u"h"},
    {u'х', u"x"},
    {u'Ц', u"C"},  //24
    {u'ц', u"c"},
    {u'Ч', u"CH"}, //25
    {u'Ч', u"Ch"},
    {u'ч', u"ch"},
    {u'Ш', u"SH"}, //26
    {u'Ш', u"Sh"},
    {u'ш', u"sh"},
    {u'Щ', u"W"},  //27
    {u'Щ', u"SHH"},
    {u'Щ', u"SHh"},
    {u'Щ', u"Shh"},
    {u'щ', u"w"},
    {u'щ', u"shh"},
    {u'Ъ', u"QQ"}, //28
    {u'ъ', u"qq"},
    {u'Ы', u"Y"},  //29
    {u'ы', u"y"},
    {u'Ь', u"Q"},  //30
    {u'ь', u"q"},
    {u'Э', u"Ä"},  //31
    {u'Э', u"JE"},
    {u'Э', u"Je"},
    {u'э', u"je"},
    {u'Ю', u"Ü"},  //32
    {u'Ю', u"JU"},
    {u'Ю', u"Ju"},
    {u'Ю', u"YU"},
    {u'Ю', u"Yu"},
    {u'ю', u"ü"},
    {u'ю', u"ju"},
    {u'ю', u"yu"},
    {u'Я', u"JA"}, //33
    {u'Я', u"Ja"},
    {u'Я', u"YA"},
    {u'Я', u"Ya"},
    {u'я', u"ja"},
    {u'я', u"ya"}
};

#endif
