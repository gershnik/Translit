// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_MAPPER_HPP_INCLUDED
#define TRANSLIT_HEADER_MAPPER_HPP_INCLUDED

#include "MultiMatch.hpp"

template<class DstChar, class SrcChar, size_t N, size_t M>
struct Mapping {
    const CTString<DstChar, M> dst;
    const CTString<SrcChar, N> src;
    
    constexpr Mapping(DstChar dst_, const SrcChar (&src_)[N + 1]) noexcept:
        dst{{dst_, 0}},
        src(src_)
    {}
    constexpr Mapping(const DstChar (&dst_)[M + 1], const SrcChar (&src_)[N + 1]) noexcept:
        dst(dst_),
        src(src_)
    {}
};

template<class DstChar, class SrcChar, size_t N>
Mapping(DstChar dst, const SrcChar (&src)[N]) -> Mapping<DstChar, SrcChar, N - 1, 1>;

template<class DstChar, class SrcChar, size_t N, size_t M>
Mapping(const DstChar (&dst)[M], const SrcChar (&src)[N]) -> Mapping<DstChar, SrcChar, N - 1, M - 1>;


template<CTString... Str>
constexpr auto combinedIndices() {
    static_assert((0 + ... + Str.size()) <= std::numeric_limits<uint8_t>::max(), "combined string length cannot fit in uint8_t");
    std::array<uint8_t, sizeof...(Str) + 1> ret = {0, Str.size()...};
    for (int i = 1; i < std::size(ret); ++i)
        ret[i] += ret[i - 1];
    return ret;
}


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

template<class DstChar, std::ranges::forward_range Range>
constexpr auto nullPrefixMapper(const Range & range) {
    using Payload = std::basic_string_view<DstChar>;
    return PrefixMappingResult<Payload, std::ranges::iterator_t<const Range>>{std::ranges::begin(range), std::nullopt, true};
}

template<std::ranges::forward_range Range, Mapping First, Mapping... Rest>
requires(SameCharType<First.src, Rest.src...> &&
         SameCharType<First.dst, Rest.dst...> &&
         std::is_same_v<typename std::ranges::range_value_t<Range>, CharTypeOf<First.src>>)
constexpr auto makePrefixMapper() {
    
    using Char = CharTypeOf<First.dst>;
    using StringView = std::basic_string_view<Char>;
    using Iterator = std::ranges::iterator_t<const Range>;
    using ReturnType = PrefixMappingResult<StringView, Iterator>;
    
    static constexpr auto multiMatch = makeMultiMatch<First.src, Rest.src...>();
    static constexpr auto combined = (First.dst + ... + Rest.dst);
    static constexpr auto mappings = combinedIndices<First.dst, Rest.dst...>();
    
    auto func = [](const Range & range) -> ReturnType {
        
        auto res = prefixMatch(multiMatch, range);
        if (res.index != multiMatch.noMatch) {
            auto offset = mappings[res.index];
            auto len = mappings[res.index + 1] - offset;
            return {res.next, StringView(combined.chars + offset, len), res.definite};
        }
        return {res.next, std::nullopt, res.definite};
    };
    
    return func;
}

template<std::ranges::forward_range Range, CTString Default, Mapping First, Mapping... Rest>
requires(SameCharType<First.src, Rest.src...> &&
         SameCharType<Default, First.dst> &&
         SameCharType<First.dst, Rest.dst...> &&
         std::is_same_v<typename std::ranges::range_value_t<Range>, CharTypeOf<First.src>>)
constexpr auto makeMapper() {
    
    using Char = CharTypeOf<First.dst>;
    using StringView = std::basic_string_view<Char>;
    
    static constexpr auto multiMatch = makeMultiMatch<First.src, Rest.src...>();
    static constexpr auto combined = (First.dst + ... + Rest.dst) + Default;
    static constexpr auto mappings = combinedIndices<First.dst, Rest.dst..., Default>();
    
    auto func = [](const Range & range) {
        
        auto res = match(multiMatch, range);
        auto offset = mappings[res];
        auto len = mappings[res + 1] - offset;
        
        return StringView(combined.chars + offset, len);
    };
    
    return func;
}


#endif


