// Copyright (c) 2023, Eugene Gershnik
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef TRANSLIT_HEADER_MULTI_MATCH_HPP_INCLUDED
#define TRANSLIT_HEADER_MULTI_MATCH_HPP_INCLUDED

#include <type_traits>
#include <concepts>
#include <ranges>
#include <algorithm>
#include <array>
#include <vector>
#include <string_view>
#include <climits>
#include <stdexcept>

template<class Char, size_t N>
struct CTString {
    using char_type = Char;

    Char chars[N + 1];

    constexpr CTString(const Char (&src)[N + 1]) noexcept
    {
        std::copy(src, src + N + 1, chars);
    }

    constexpr auto size() const -> size_t { return N; }

    constexpr auto operator[](size_t i) const -> Char { return chars[i]; }

    friend constexpr bool operator==(const CTString & lhs, const CTString & rhs) {
        return std::equal(lhs.chars, lhs.chars + N, rhs.chars);
    }

    constexpr auto begin() const { return chars; }
    constexpr auto end() const { return chars + N; }
};

template<class Char, size_t N>
CTString(const Char (&src)[N]) -> CTString<Char, N - 1>;


template<CTString First, CTString... Rest>
constexpr bool SameCharType = (std::is_same_v<typename decltype(First)::char_type, typename decltype(Rest)::char_type> && ...);

template<CTString First>
using CharTypeOf = typename decltype(First)::char_type;

template<class T, size_t MaxSize>
class StaticVector {
private:
    using Array = std::array<T, MaxSize>;
public:
    using iterator = Array::iterator;
    using const_iterator = Array::const_iterator;

    constexpr auto begin() const { return m_buf.begin(); }
    constexpr auto begin() { return m_buf.begin(); }
    constexpr auto end() const { return m_buf.begin() + m_size; }
    constexpr auto end() { return m_buf.begin() + m_size; }
    constexpr auto size() const { return m_size; }
    constexpr auto operator[](size_t i) -> T & { return m_buf[i]; }
    constexpr auto operator[](size_t i) const -> const T & { return m_buf[i]; }

    constexpr auto insert(const_iterator where, const T & val) {
        auto p = end();
        for(; p != where; --p) {
            *p = *(p - 1);
        }
        *p = val;
        ++m_size;
        return p;
    }
    constexpr void push_back(const T & val) {
        m_buf[m_size++] = val;
    }
    
private:
    size_t m_size = 0;
    Array m_buf{};
};

namespace Impl {

    template<class Char, size_t MaxSize>
    struct Inventory {
        struct State  {
            static constexpr size_t notPresent = size_t(-1);
            
            std::basic_string_view<Char> str;
            size_t index = notPresent;
            size_t payloadIdx = notPresent;
            bool successful = false;
            bool final = false;

            constexpr friend auto operator<(const State & lhs, const State & rhs) {
                return lhs.str < rhs.str;
            }
        };

        StaticVector<Char, MaxSize> inputs;
        StaticVector<State, MaxSize> states;
        size_t outcomeCount = 0;
    };

    template<CTString First, CTString... Rest>
    requires(SameCharType<First, Rest...>)
    consteval auto makeInventory() {

        constexpr size_t maxSize = 1 + (First.size() + ... + Rest.size());
        
        Inventory<CharTypeOf<First>, maxSize> inventory;
        using State = decltype(inventory)::State;
        
        inventory.states.push_back({.final = true});
        
        constexpr std::basic_string_view<CharTypeOf<First>> strings[] =
            { {First.begin(), First.size()}, {Rest.begin(), Rest.size()}... };

        for(size_t idx = 0; idx < std::size(strings); ++idx) {

            auto string = strings[idx];

            for (auto c: string) {
                auto it = std::lower_bound(inventory.inputs.begin(), inventory.inputs.end(), c);
                if (it == inventory.inputs.end() || *it != c)
                    inventory.inputs.insert(it, c);
            }

            for (size_t i = 1; i < string.size(); ++i) {
                State value{.str = {string.begin(), string.begin() + i}, .index = State::notPresent, .payloadIdx = State::notPresent, .successful = false, .final = false};
                auto it = std::lower_bound(inventory.states.begin(), inventory.states.end(), value);
                if (it == inventory.states.end() || it->str != value.str) {
                    it = inventory.states.insert(it, value);
                } else {
                    it->final = false;
                }
            }

            State value{.str = {string.begin(), string.end()}, .index = State::notPresent, .payloadIdx = idx, .successful = true, .final = true};
            auto it = std::lower_bound(inventory.states.begin(), inventory.states.end(), value);
            if (it == inventory.states.end() || it->str != value.str) {
                it = inventory.states.insert(it, value);
            } else {
                it->successful = true;
                it->payloadIdx = idx;
            }
        }

        inventory.outcomeCount = 0;
        size_t intermediateCount = inventory.states.size();
        for(auto & state: inventory.states) {
            if (state.successful) {
                state.index = inventory.outcomeCount++;
            } else {
                state.index = --intermediateCount;
            }
        }

        return inventory;
    }

    struct Sizes {
        size_t inputs;
        size_t states;
        size_t outcomes;
        size_t noMatch;
    };

    template<std::unsigned_integral SizeType>
    class Outcome {
    public:
        constexpr Outcome() noexcept = default;
        
        constexpr Outcome(SizeType value, bool final) noexcept :
            m_value(value | (SizeType(final) << (sizeof(SizeType) * CHAR_BIT - 1)))
        {}

        constexpr bool final() const noexcept
            { return bool(m_value >> (sizeof(SizeType) * CHAR_BIT - 1)); }
        constexpr SizeType value() const noexcept
            { return m_value & ~(SizeType(1) << (sizeof(SizeType) * CHAR_BIT - 1)); }

        template<size_t MaxValue>
        static constexpr bool isSufficientFor() {
            return MaxValue <= ~(SizeType(1) << (sizeof(SizeType) * CHAR_BIT - 1));
        }
    private:
        SizeType m_value = 0;
    };
}

template<class Char, Impl::Sizes Sizes>
requires(Sizes.outcomes > 0)
struct MultiMatch {
    static constexpr size_t noMatch = Sizes.noMatch;

    using CharType = Char;
    using SizeType = std::conditional_t<Impl::Outcome<unsigned char>::isSufficientFor<Sizes.states>(),        unsigned char,
                     std::conditional_t<Impl::Outcome<unsigned short>::isSufficientFor<Sizes.states>(),       unsigned short,
                     std::conditional_t<Impl::Outcome<unsigned int>::isSufficientFor<Sizes.states>(),         unsigned int,
                     std::conditional_t<Impl::Outcome<unsigned long>::isSufficientFor<Sizes.states>(),        unsigned long,
                     std::conditional_t<Impl::Outcome<unsigned long long>::isSufficientFor<Sizes.states>(),   unsigned long long,
                     void>>>>>;
    static_assert(!std::is_same_v<SizeType, void>, "Number of states cannot fit in any supported type");

    using OutcomeType = Impl::Outcome<SizeType>;

    static constexpr SizeType noState = SizeType(-1);
    

    std::array<Char, Sizes.inputs> inputs;
    std::array<OutcomeType, Sizes.outcomes> outcomes;
    SizeType startState;
    std::array<SizeType, Sizes.inputs * Sizes.states> transitions;
};

template<CTString First, CTString... Rest>
requires(SameCharType<First, Rest...>)
consteval auto makeMultiMatch() {

    constexpr auto inventory = Impl::makeInventory<First, Rest...>();
    constexpr Impl::Sizes sizes{inventory.inputs.size(), inventory.states.size(), inventory.outcomeCount, 1 + sizeof...(Rest)};
    MultiMatch<CharTypeOf<First>, sizes> ret{};

    using SizeType = decltype(ret)::SizeType;
    using OutcomeType = decltype(ret)::OutcomeType;

    std::copy(inventory.inputs.begin(), inventory.inputs.end(), ret.inputs.begin());
    for(auto & state: inventory.states) {
        if (state.successful) {
            ret.outcomes[state.index] = OutcomeType{SizeType(state.payloadIdx), state.final};
        }
    }
    ret.startState = inventory.states[0].index;
    
    std::fill(ret.transitions.begin(), ret.transitions.end(), ret.noState);
    std::vector<size_t> stateStack({0});
    for(size_t i = 1; i < inventory.states.size(); ++i) {
        auto & state = inventory.states[i];
        auto newChar = state.str.back();
        
        auto it = std::lower_bound(inventory.inputs.begin(), inventory.inputs.end(), newChar);
        if (it == inventory.inputs.end() || *it != newChar)
            throw std::logic_error("character not present");
        auto charIdx = it - inventory.inputs.begin();
        
        for ( ; ; ) {
            auto & prevState = inventory.states[stateStack.back()];
            if (state.str.size() == prevState.str.size() + 1 && state.str.substr(0, state.str.size() - 1) == prevState.str) {
                ret.transitions[prevState.index * inventory.inputs.size() + charIdx] = state.index;
                break;
            }
            stateStack.pop_back();
        }
        stateStack.push_back(i);
    }

    
    return ret;
}

template<class It>
struct PrefixMatchResult {
    /**
      End of match
      If index == noMatch always stays at the start of input
    */
    It next;
    /** The index of the successful match if successful. noMatch otherwise */
    size_t index;
    /** Whether the answer is definite and won't change with larger input */
    bool definite;
};

template<class Matcher, std::ranges::forward_range Range>
requires(std::is_same_v<typename std::ranges::range_value_t<Range>, typename Matcher::CharType>)
constexpr auto prefixMatch(const Matcher & matcher, Range && r) noexcept -> PrefixMatchResult<std::ranges::borrowed_iterator_t<Range>> {

    using Result = PrefixMatchResult<std::ranges::borrowed_iterator_t<Range>>;
    
    const auto first = std::ranges::begin(r);
    const auto last = std::ranges::end(r);

    auto currentState = matcher.startState;
    auto lastMatchedState = matcher.noState;
    auto current = first;
    auto consumed = first;
    bool final = true;
    for( ; ; ) {

        if (currentState < matcher.outcomes.size()) {
            consumed = current;
            lastMatchedState = currentState;
        }
        
        if (current == last) {
            final = false;
            break;
        }

        typename Matcher::CharType c = *current;
        auto it = std::lower_bound(matcher.inputs.begin(), matcher.inputs.end(), c);
        if (it == matcher.inputs.end() || *it != c)
            break;
        size_t inputIdx = it - matcher.inputs.begin();
        
        auto nextState = matcher.transitions[currentState * matcher.inputs.size() + inputIdx];
        if (nextState == matcher.noState)
            break;
        
        currentState = nextState;
        ++current;
    }
    if (lastMatchedState != matcher.noState) {
        auto & outcome = matcher.outcomes[lastMatchedState];
        return Result{consumed, outcome.value(), final || outcome.final()};
    }
    return Result{first, Matcher::noMatch, final || matcher.inputs.size() == 0};
}

template<class Matcher, std::ranges::forward_range Range>
requires(std::is_same_v<typename std::ranges::range_value_t<Range>, typename Matcher::CharType>)
constexpr auto match(const Matcher & matcher, Range && r) noexcept -> size_t {

    auto currentState = matcher.startState;
    for(typename Matcher::CharType c: r) {
        auto it = std::lower_bound(matcher.inputs.begin(), matcher.inputs.end(), c);
        if (it == matcher.inputs.end() || *it != c)
            return Matcher::noMatch;
        size_t inputIdx = it - matcher.inputs.begin();
        
        auto nextState = matcher.transitions[currentState * matcher.inputs.size() + inputIdx];
        if (nextState == matcher.noState)
            return Matcher::noMatch;
        
        currentState = nextState;
    }
    if (currentState < matcher.outcomes.size()) {
        auto & outcome = matcher.outcomes[currentState];
        return outcome.value();
    }
    return Matcher::noMatch;
}

#ifndef NDEBUG

    #include <iostream>
    #include <iomanip>
    #include <string>

    template<class Char, Impl::Sizes Sizes>
    void debugPrint(const MultiMatch<Char, Sizes> & val) {
        std::cout << "chars: ";
        for(auto c: val.inputs) {
            std::cout << char(c);
        }
        std::cout << "\noutcomes: ";
        for(auto outcome: val.outcomes) {
            std::cout << size_t(outcome.value());
            if (!outcome.final())
                std::cout << "[i]";
            std::cout << " ";
        }
        std::cout << "\nstart state: " << size_t(val.startState);
        std::cout << "\ntransitions:\n";
        size_t maxTrSize = 0;
        for(auto tr: val.transitions) {
            if (tr == decltype(tr)(-1))
                maxTrSize = std::max(maxTrSize, size_t(1));
            else
                maxTrSize = std::max(maxTrSize, std::to_string(size_t(tr)).size());
        }

        std::ios oldState(nullptr);
        oldState.copyfmt(std::cout);
        std::cout << std::setfill(' ');
        for(size_t y = 0; y < Sizes.states; ++y) {
                for(size_t x = 0; x < Sizes.inputs; ++x) {
                auto tr = val.transitions[y * Sizes.inputs + x];
                std::cout << std::setw(int(maxTrSize));
                if (tr == decltype(tr)(-1))
                    std::cout << '*';
                else
                    std::cout << size_t(tr);
                std::cout << ' ';
            }
            std::cout << '\n';
        }
        std::cout << '\n';
        std::cout.copyfmt(oldState);
    }

#endif

#endif
