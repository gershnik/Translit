// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TRANSLITERATOR_REGISTRY_H_INCLUDED
#define TRANSLIT_HEADER_TRANSLITERATOR_REGISTRY_H_INCLUDED

#include "Transliterator.h"


auto getTransliterator(const sys_string & name) -> Transliterator &;

#endif
