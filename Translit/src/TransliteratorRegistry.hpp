// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TRANSLITERATOR_REGISTRY_HPP_INCLUDED
#define TRANSLIT_HEADER_TRANSLITERATOR_REGISTRY_HPP_INCLUDED

#include "Transliterator.hpp"


auto getTransliterator(const sys_string & name) -> Transliterator &;

#endif
