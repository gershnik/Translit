// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_MAPPER_HPP_INCLUDED
#define TRANSLIT_HEADER_MAPPER_HPP_INCLUDED

#include "MultiMatch.hpp"

template<class T, class Char, size_t N>
struct Mapping {
    const T dst;
    const CTString<Char, N> src;
    
    constexpr Mapping(T c, const Char (&arr)[N + 1]) noexcept:
        dst(c),
        src(arr)
    {}
};

template<class T, class Char, size_t N>
Mapping(T c, const Char (&arr)[N]) -> Mapping<T, Char, N - 1>;

template<class T>
struct Value {
    const T value;
    
    constexpr Value(T v) noexcept:
        value(v)
    {}
};


template<class Payload, class It>
struct PrefixMappingResult {
    /**
     End of match
     If !payload always stays at the start of input
     */
    It next;
    /** The mapping of the match, if successful */
    std::optional<Payload> payload;
    /** Whether the answer is definite and won't change with larger input */
    bool definite;
};

template<class Payload, std::ranges::forward_range Range>
constexpr auto nullPrefixMapper(const Range & range) {
    return PrefixMappingResult<Payload, std::ranges::iterator_t<const Range>>{std::ranges::begin(range), std::nullopt, true};
}

template<std::ranges::forward_range Range, Mapping First, Mapping... Rest>
requires(SameCharType<First.src, Rest.src...> &&
         (std::is_same_v<decltype(First.dst), decltype(Rest.dst)> && ...) &&
         std::is_same_v<typename std::ranges::range_value_t<Range>, CharTypeOf<First.src>>)
constexpr auto makePrefixMapper() {
    
    using Payload = std::remove_const_t<decltype(First.dst)>;
    using Char = CharTypeOf<First.src>;
    
    auto func = [](const Range & range) {
        using Iterator = std::ranges::iterator_t<const Range>;
        
        static constexpr auto multiMatch = makeMultiMatch<First.src, Rest.src...>();
        static constexpr Payload mappings[1 + sizeof...(Rest)] = {First.dst, Rest.dst...};
        
        auto res = prefixMatch(multiMatch, range);
        if (res.index != multiMatch.noMatch)
            return PrefixMappingResult<Payload, Iterator>{res.next, mappings[res.index], res.definite};
        return PrefixMappingResult<Payload, Iterator>{res.next, std::nullopt, res.definite};
    };
    
    return func;
}

template<std::ranges::forward_range Range, Value Default, Mapping First, Mapping... Rest>
requires(SameCharType<First.src, Rest.src...> &&
         std::is_same_v<decltype(Default.value), decltype(First.dst)> &&
         (std::is_same_v<decltype(First.dst), decltype(Rest.dst)> && ...) &&
         std::is_same_v<typename std::ranges::range_value_t<Range>, CharTypeOf<First.src>>)
constexpr auto makeMapper() {
    
    using Payload = std::remove_const_t<decltype(First.dst)>;
    using Char = CharTypeOf<First.src>;
    
    auto func = [](const Range & range) {
        using Iterator = std::ranges::iterator_t<const Range>;
        
        static constexpr auto multiMatch = makeMultiMatch<First.src, Rest.src...>();
        static constexpr Payload mappings[2 + sizeof...(Rest)] = {First.dst, Rest.dst..., Default.value};
        
        auto res = match(multiMatch, range);
        return mappings[res];
    };
    
    return func;
}


#endif


