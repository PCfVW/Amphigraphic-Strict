// after.cpp - Stoic-compliant C++
// Same functionality as before.cpp, but following Stoic rules.
//
// Fixes 1-3, 8-9 address Stoic's five core rules.
// Fixes 4-7 are additional best practices that complement Stoic.
// Fixes 10-13 demonstrate the use of Stoic comment markers.

// Rule 1: Prefer modules (C++20)
// In a real project, this would be:
//   import std;
//   import myproject.utils;
// Fallback for pre-C++20:
#pragma once  // If this were a header
#include <array>
#include <algorithm>
#include <cstdint>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <source_location>
#include <string>
#include <vector>

// --- FIX 1: Smart Pointers Instead of Manual Memory ---
// Stoic: Use std::unique_ptr for sole ownership

class ResourceManager {
    std::unique_ptr<int[]> data;  // Ownership is explicit
    size_t size;

public:
    explicit ResourceManager(size_t n)
        : data(std::make_unique<int[]>(n))  // RAII from construction
        , size(n)
    {}

    void process() {
        if (size == 0) {
            return;  // Safe: unique_ptr handles cleanup automatically
        }
        // ... processing ...
    }

    // No destructor needed! unique_ptr handles cleanup.
};

// Stoic: Exception-safe, leak-free code
void safeFunction() {
    auto buffer = std::make_unique<int[]>(100);

    if (someCondition()) {
        return;  // Safe: buffer automatically freed
    }

    process(buffer.get());  // Pass raw pointer for non-owning access
    // Automatic cleanup at end of scope
}

// --- FIX 2: Templates Instead of Function-like Macros ---
// Stoic: Use inline functions or templates

template<typename T>
inline T max_of(T a, T b) {
    return (a > b) ? a : b;
}

template<typename T>
inline T square(T x) {
    return x * x;
}

void noMacroProblems() {
    int x = 5;
    int y = 3;

    // Safe: x++ evaluated exactly once
    int max_val = max_of(x++, y);

    // Safe: function called exactly once
    int squared = square(expensiveComputation());
}

// --- FIX 3: const Instead of Constant Macros ---
// Stoic: Use const variables (not constexpr by default — see FIX 8)

inline const double pi = 3.14159265358979;
inline const size_t default_buffer_size = 1024;
inline const std::string_view error_message = "An error occurred";

// Benefits:
// - Full type safety
// - Proper scoping (can be in namespace)
// - Debugger shows variable name
// - No macro pollution

void useConstants() {
    double area = pi * radius * radius;  // Type-safe, debuggable
    std::vector<char> buffer(default_buffer_size);  // Clear size, proper type
}

// --- FIX 4: Modules Eliminate Header Complexity ---
// Stoic: With C++20 modules, no include order issues

// Instead of:
//   #include "derived.h"
//   #include "base.h"
// Use:
//   import myproject.base;
//   import myproject.derived;
// Order doesn't matter with modules!

// No macro pollution: modules don't export macros
// Each module is self-contained

// For pre-C++20: use scoped enums instead of macros
enum class StatusCode {
    Success = 0,
    Error = 1
};

// --- FIX 5: Clear Ownership with Smart Pointers ---
// Stoic: Ownership is always explicit

class Container {
    std::vector<std::unique_ptr<Item>> items;  // Owns the items

public:
    Container() = default;

    // OWNERSHIP: Transfers ownership of item into container
    void add(std::unique_ptr<Item> item) {
        items.push_back(std::move(item));
    }

    // Non-owning access (caller must not store long-term)
    Item* get(int index) {
        return items[index].get();  // BORROW: Caller does not own
    }

    // Const access for safety
    const Item* get(int index) const {
        return items[index].get();
    }

    // No destructor needed! vector<unique_ptr> handles cleanup.
};

// --- FIX 6: if constexpr Instead of Preprocessor Logic ---
// Stoic: Use language features for compile-time decisions

// Note: if constexpr REQUIRES a constexpr condition — this is a valid use case
constexpr bool use_feature_x = true;  // constexpr required for if constexpr

void conditionalCode() {
    if constexpr (use_feature_x) {
        doFeatureX();
    } else {
        doAlternative();
    }
    // Benefits:
    // - Both branches are type-checked
    // - Dead code is properly eliminated by compiler
    // - Refactoring tools see all code
    // - Debugger understands the logic
}

// --- FIX 7: using Instead of Type Alias Macros ---
// Stoic: Use using declarations

using StringList = std::vector<std::string>;
using IntPair = std::pair<int, int>;

// Benefits:
// - Template parameter support: template<typename T> using Vec = std::vector<T>;
// - Clear error messages
// - Can forward declare in some cases
// - Proper scoping

// Template alias example:
template<typename T>
using UniqueVec = std::vector<std::unique_ptr<T>>;

// --- Bonus: Source Location Instead of __FILE__/__LINE__ Macros ---
// Stoic: Use std::source_location (C++20)

void log_message(
    std::string_view message,
    const std::source_location& loc = std::source_location::current()
) {
    std::cout << loc.file_name() << ":" << loc.line()
              << " [" << loc.function_name() << "] "
              << message << std::endl;
}

// Usage: log_message("Something happened");
// Output: after.cpp:142 [conditionalCode] Something happened

// --- FIX 8: const by Default, constexpr Only When Required ---
// Stoic: Avoid over-applying constexpr

// Use const for simple values — always works, no surprises:
const std::string app_name = "MyApp";  // const, not constexpr
const int default_timeout = 30;        // const works fine

// Use inline for functions — compiler optimizes anyway:
inline std::string getName() {
    return "hello";  // No constexpr needed
}

inline std::vector<int> getNumbers() {
    return {1, 2, 3};  // No constexpr needed
}

// Runtime values stay runtime — no false promises:
inline auto loadConfig(const char* path) {
    // File I/O happens at runtime, not compile-time
    return parseConfigFile(path);
}

// Classes with non-literal members — just don't use constexpr:
class DataProcessor {
    std::string name;
public:
    DataProcessor(const char* n) : name(n) {}  // Normal constructor, works fine
};

// ONLY use constexpr when compile-time evaluation is REQUIRED:
constexpr size_t buffer_size = 1024;           // Template arg needs constexpr
std::array<char, buffer_size> buffer;          // This is why we need constexpr

constexpr int factorial(int n) {               // Simple, single-expression
    return n <= 1 ? 1 : n * factorial(n - 1);
}
static_assert(factorial(5) == 120);            // Compile-time check needs constexpr

// --- FIX 9: Document Preconditions and UB ---
// Stoic: Make constraints visible to AI and developers

template<typename T>
class SafeContainer {
    std::vector<T> data;

public:
    // PRECONDITION: index must be in range [0, size())
    T& at(size_t index) {
        return data[index];
    }

    // UB: calling front() on empty container is undefined behavior
    // Consider using front_or() or checking empty() first
    const T& front() const {
        return data.front();
    }

    // Stoic: Prefer std::optional for operations that might fail
    std::optional<T> average() const {
        if (data.empty()) {
            return std::nullopt;  // Safe: no division by zero
        }
        T sum = T{};
        for (const auto& item : data) sum += item;
        return sum / static_cast<T>(data.size());
    }

    // Stoic: Safe accessor with bounds check
    std::optional<std::reference_wrapper<const T>> get(size_t index) const {
        if (index >= data.size()) {
            return std::nullopt;
        }
        return std::cref(data[index]);
    }

    [[nodiscard]] bool empty() const { return data.empty(); }
    [[nodiscard]] size_t size() const { return data.size(); }
};

// Stoic: Document preconditions, or use safe alternatives
void processIndexSafe(const std::vector<int>& v, size_t index) {
    // PRECONDITION: index must be in range [0, v.size())
    if (index < v.size()) {
        std::cout << v[index];
    }
    // Or use .at() which throws on out-of-bounds
}

// Stoic: Use references for non-null, or gsl::not_null
void processReference(int& value) {
    value = 42;  // Safe: references cannot be null
}

// Stoic: If pointer needed, document the constraint
// PRECONDITION: ptr must not be null
void processPointerDocumented(int* ptr) {
    *ptr = 42;
}

// --- FIX 10: Document Map Insertion with MAP_ACCESS ---
// Stoic: Use .find() for reads, document intentional insertions

std::map<std::string, int> counters;

void incrementCounterSafe(const std::string& name) {
    auto it = counters.find(name);
    if (it != counters.end()) {
        it->second++;  // Safe: only increments existing entries
    } else {
        counters[name] = 1;  // MAP_ACCESS: intentional insertion of new counter
    }
}

int getCounterSafe(const std::string& name) {
    auto it = counters.find(name);
    if (it != counters.end()) {
        return it->second;  // Safe read, no mutation
    }
    return 0;  // Default without inserting
}

void setCounter(const std::string& name, int value) {
    counters[name] = value;  // MAP_ACCESS: intentional insertion/update
}

// --- FIX 11: Document Intentional Copy with COPY ---
// Stoic: Mark pass-by-value when copy is intentional

struct GameState {
    int score;
    std::vector<int> moves;
    void applyMove(int m) { moves.push_back(m); score += m; }
};

// COPY: State copied intentionally for rollback on failure
bool tryMoveSafe(GameState state, int move) {
    state.applyMove(move);
    if (state.score < 0) {
        return false;  // Original state unchanged - copy was intentional!
    }
    return true;
}

// --- FIX 12: Document Type Limits with TYPE_LIMIT ---
// Stoic: Make numeric constraints visible

typedef unsigned char StepCount;    // TYPE_LIMIT: max 255 steps per plan (0-255)
typedef std::uint8_t NodeId;        // TYPE_LIMIT: max 255 node ID (0-255)
typedef std::uint16_t PredicateId;  // TYPE_LIMIT: max 65535 predicates (0-65535)

// PRECONDITION: maxSteps must be achievable within StepCount range (0-255)
void planRouteSafe(StepCount maxSteps) {
    for (StepCount i = 0; i < maxSteps; ++i) {  // Safe: loop var matches type
        // ...
    }
}

// --- FIX 13: Document Platform-Specific Code with PLATFORM ---
// Stoic: Make conditional compilation intent clear

// PLATFORM: Windows uses high-resolution performance counter
#if defined(_MSC_VER)
    void platformSpecificInitSafe() {
        // PLATFORM: Windows-specific initialization
        // Uses QueryPerformanceCounter for timing
    }
#else
    void platformSpecificInitSafe() {
        // PLATFORM: POSIX fallback uses clock_gettime
        // Uses CLOCK_MONOTONIC for timing
    }
#endif

// PLATFORM: Memory allocation strategy varies by build configuration
#if defined(NDEBUG)
    // PLATFORM: Release builds may use custom allocators
    inline const bool use_custom_allocator = true;
#else
    // PLATFORM: Debug builds use standard allocator for better diagnostics
    inline const bool use_custom_allocator = false;
#endif

// Helper declarations for compilation
bool someCondition() { return false; }
void process(int*) {}
int expensiveComputation() { return 42; }
double radius = 1.0;
class Item {};
void doFeatureX() {}
void doAlternative() {}
int parseConfigFile(const char*) { return 0; }
