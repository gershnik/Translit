// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_TRANSLITERATOR_HPP_INCLUDED
#define TRANSLIT_HEADER_TRANSLITERATOR_HPP_INCLUDED

#include "StateMachine.hpp"

class Transliterator {
public:
    using SizeType = unsigned short;
private:
    using StateMachineType = StateMachine<char16_t, SizeType>;
public:
    Transliterator() = default;
    
    template<std::ranges::range Range>
    requires(std::is_convertible_v<std::tuple_element_t<0, std::ranges::range_value_t<Range>>, char16_t> &&
             std::is_convertible_v<std::tuple_element_t<1, std::ranges::range_value_t<Range>>, const char16_t *>)
    Transliterator(Range && range): m_sm(range)
    {}
    
    void append(const sys_string & str);
    
    auto result() const -> std::u16string_view
        { return m_translit; }
    auto completedSize() const -> SizeType
        { return m_translitCompletedSize; }
    auto matchedSomething() const -> bool
        { return m_matchedSomething; }
    
    void clear()  {
        m_prefix.clear();
        m_translit.clear();
        m_translitCompletedSize = 0;
        m_matchedSomething = false;
    }
    
    void clearCompleted() {
        m_translit.erase(m_translit.begin(), m_translit.begin() + m_translitCompletedSize);
        m_translitCompletedSize = 0;
        if (m_translit.empty())
            m_matchedSomething = false;
    }
    
private:
    StateMachineType m_sm;
    
    std::u16string m_prefix;
    std::u16string m_translit;
    SizeType m_translitCompletedSize = 0;
    bool m_matchedSomething = false;
};

#endif
