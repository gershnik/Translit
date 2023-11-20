// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#include "TransliteratorRegistry.h"
#include "TableRU.h"
#include "TableHE.h"

static std::map<sys_string, Transliterator> g_transliterators {
    { S("ru"), Transliterator::from(g_tableRu) },
    { S("he"), Transliterator::from(g_tableHe) }
};


auto getTransliterator(const sys_string & name) -> Transliterator & {
    return g_transliterators[name];
}
