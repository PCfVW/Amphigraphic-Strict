# Stoic — Strict C++ for AI-Assisted Development

*Stoic: enduring complexity with discipline—C++ without the drama.*

C++ is powerful but perilous for AI code generation. Its vast feature surface, implicit behaviors, and undefined behavior traps create abundant opportunities for AI to generate code that compiles but fails unpredictably. **Stoic** is a minimal, focused subset of C++ that eliminates the most treacherous patterns.

> **Empirical basis:** Stoic's rules are *inferred* from general LLM error research rather than C++-specific studies. No direct study has yet measured AI accuracy improvements for C++-specific constraints—this represents an open research opportunity.

> **Scope:** This initial version of Stoic addresses five C++ weaknesses: header complexity, manual memory management, preprocessor macros, `constexpr` over-application, and undocumented preconditions/undefined behavior. Additionally, Stoic provides comment markers for documenting patterns that AI frequently misunderstands: map access behavior, intentional copies, type limits, and platform-specific code.

## Quick Start

```bash
# Use clang-tidy with the provided configuration
clang-tidy -p build/ --config-file=.clang-tidy src/*.cpp
```

## What Stoic Fixes (Initial Scope)

| C++ Weakness | Stoic Rule | AI Benefit |
|--------------|------------|------------|
| Header complexity | Prefer C++20 modules | AI sees explicit dependencies, no include-order bugs |
| Manual memory management | Smart pointers only | AI cannot generate memory leaks or use-after-free |
| Preprocessor macros | Banned (with narrow exceptions) | AI generates visible, debuggable code |
| `constexpr` over-application | `const` by default | AI stops generating compilation failures |
| Undocumented preconditions | `// PRECONDITION:` markers | AI sees constraints in context |
| Undefined behavior traps | `// UB:` markers | AI cannot assume safety where UB lurks |
| Map insertion side effects | `// MAP_ACCESS:` markers | AI knows when `operator[]` intentionally inserts |
| Unintentional copies | `// COPY:` markers | AI knows when pass-by-value is intentional |
| Type alias constraints | `// TYPE_LIMIT:` markers | AI knows numeric bounds of custom types |
| Platform-specific code | `// PLATFORM:` markers | AI understands conditional compilation intent |

## The Rules

### Rule 1: Prefer Modules Over Headers

Headers introduce implicit dependencies, include-order sensitivity, and macro pollution. Modules make dependencies explicit and self-contained.

```cpp
// BANNED in Stoic
#include <vector>
#include <string>
#include "myproject/utils.h"

// Stoic: Use modules (C++20)
import std;
import myproject.utils;
```

**Why this matters for AI:**
- No include guards to forget or mangle
- No transitive includes creating hidden dependencies
- No macro leakage between translation units
- Explicit `export` declarations show what's public

**Enforcement:** Require `-fmodules` (Clang) or `/std:c++20 /experimental:module` (MSVC). Use `modernize-use-modules` when available.

**Fallback for pre-C++20:** If modules are unavailable, use the following header hygiene rules:
- All headers must be self-contained (include their own dependencies)
- All headers must have `#pragma once`
- Macros restricted per Rule 3

### Rule 2: Smart Pointers Only

Raw owning pointers are the leading cause of memory bugs. Stoic bans manual `new`/`delete` entirely.

```cpp
// BANNED in Stoic
MyClass* obj = new MyClass();
// ... code that might throw or return early ...
delete obj;  // Leak if not reached

// Stoic: Smart pointers only
auto obj = std::make_unique<MyClass>();
// Automatic cleanup, exception-safe
```

**Ownership rules:**

| Ownership | Stoic Type | Use Case |
|-----------|-----------|----------|
| Sole owner | `std::unique_ptr<T>` | Default choice |
| Shared ownership | `std::shared_ptr<T>` | Only when truly needed |
| Non-owning reference | `T*` or `T&` | Borrowing, never owning |
| Optional non-owning | `T*` | May be null, never delete |

**Comment markers for ownership:**
- `// OWNERSHIP:` — documents ownership transfer
- `// BORROW:` — documents non-owning access

```cpp
// BANNED in Stoic
class Container {
    Item* items;  // Who owns this? Who deletes it?
public:
    ~Container() { delete[] items; }  // Manual management
};

// Stoic: Ownership is explicit
class Container {
    std::vector<Item> items;  // Value semantics, automatic lifetime
};

// Or if heap allocation is needed:
class Container {
    std::unique_ptr<Item[]> items;  // Ownership is clear
};
```

**Enforcement:**
- `clang-tidy`: `cppcoreguidelines-owning-memory`, `cppcoreguidelines-no-malloc`
- `clang-tidy`: `modernize-make-unique`, `modernize-make-shared`
- Compiler: `-Wold-style-cast` to catch C-style casts that might hide allocations

### Rule 3: No Preprocessor Macros

The C preprocessor performs invisible text substitution before compilation. AI models see the macro definition but not its expansion at each use site, leading to subtle bugs that are hard to diagnose.

```cpp
// BANNED in Stoic
#define MAX(a, b) ((a) > (b) ? (a) : (b))
int result = MAX(x++, y);  // x incremented twice if x > y — invisible side effect

#define DEBUG_LOG(msg) std::cout << __FILE__ << ":" << __LINE__ << " " << msg << std::endl
DEBUG_LOG("value = " << value);  // Expands unpredictably, hard to debug

// Stoic: Use language features instead
template<typename T>
inline T max_of(T a, T b) { return (a > b) ? a : b; }
int result = max_of(x++, y);  // x++ evaluated exactly once, predictable behavior

inline void debug_log(std::string_view msg, std::source_location loc = std::source_location::current()) {
    std::cout << loc.file_name() << ":" << loc.line() << " " << msg << std::endl;
}
```

**Why macros harm AI code generation:**

| Macro Problem | AI Impact |
|---------------|-----------|
| No type checking | AI cannot predict type errors at use sites |
| No scope | Macros pollute namespaces invisibly |
| Side effect duplication | AI cannot see that arguments are evaluated multiple times |
| Debugging opacity | Errors point to expansion site, not definition |
| Token pasting | `##` and `#` operators create identifiers AI cannot trace |

**Allowed exceptions (narrow):**

| Exception | Rationale | Example |
|-----------|-----------|---------|
| Include guards | Required for pre-C++20 headers | `#ifndef FOO_H` / `#define FOO_H` / `#endif` |
| `#pragma once` | Modern include guard alternative | `#pragma once` |
| Platform detection | No language alternative | `#ifdef _WIN32` |
| Feature detection | Compiler capability checks | `#if __cplusplus >= 202002L` |

**Banned patterns:**

| Pattern | Replacement |
|---------|-------------|
| Function-like macros | `inline` functions or templates |
| Constant macros | `const` variables (see warning below) |
| Type aliases via macro | `using` or `typedef` |
| Conditional compilation for logic | `if constexpr` (C++17) |
| Token pasting | Template specialization |

```cpp
// BANNED in Stoic
#define PI 3.14159265358979
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof(arr[0]))
#define STRINGIFY(x) #x

// Stoic: Language-level alternatives
inline const double pi = 3.14159265358979;  // const, not constexpr

template<typename T, std::size_t N>
inline std::size_t array_size(T (&)[N]) { return N; }
// Or use std::size() from <iterator>

// For stringification, use source_location or explicit strings
```

**Enforcement:**
- `clang-tidy`: `cppcoreguidelines-macro-usage`
- `clang-tidy`: `modernize-macro-to-enum` (for constant macros)
- Compiler: `-Wundef` to catch undefined macro usage
- Code review: Reject PRs with new `#define` outside allowed exceptions

### Rule 4: `const` by Default, Not `constexpr`

AI assistants frequently over-apply `constexpr`, generating code that fails to compile. Based on practitioner feedback, AI struggles to determine whether an expression can be evaluated at compile-time, resulting in many false positives.

| `constexpr` Problem | AI Behavior |
|---------------------|-------------|
| Context-dependent evaluation | AI doesn't know if code runs at compile-time or runtime |
| Version-dependent restrictions | AI mixes C++11/14/17/20 `constexpr` rules |
| Type compatibility | AI applies `constexpr` to non-literal types (e.g., `std::string` pre-C++20) |
| Over-application | AI adds `constexpr` speculatively, causing compilation failures |

```cpp
// BANNED in Stoic (speculative constexpr)
constexpr std::string getName() { return "hello"; }  // ERROR pre-C++20
constexpr auto config = loadFile("config.json");     // ERROR: runtime I/O

// Stoic: const by default
const double pi = 3.14159;           // Simple, always works
const int buffer_size = 1024;        // Simple, always works
inline int square(int x) { return x * x; }  // Compiler optimizes anyway

// ONLY use constexpr when compile-time evaluation is REQUIRED:
constexpr size_t array_extent = 100;
std::array<int, array_extent> arr;   // Template argument requires constexpr
```

**When `constexpr` IS appropriate:**
- Template arguments: `std::array<T, N>` requires `N` to be `constexpr`
- `static_assert` conditions
- `if constexpr` conditions
- Compile-time array bounds

**Enforcement:**
- Code review: Question every `constexpr` — is compile-time evaluation truly required?
- No automated enforcement: `constexpr` correctness requires semantic understanding that linters cannot provide

### Rule 5: Document Preconditions and Undefined Behavior

C++ lacks built-in contracts (until C++26), and many standard library operations have undefined behavior when misused. AI frequently generates code that violates preconditions or triggers UB. Stoic requires explicit documentation of these hazards.

```cpp
// BANNED in Stoic (undocumented precondition)
T& at(size_t index) {
    return data[index];  // UB if index >= size!
}

// Stoic: Document preconditions
// PRECONDITION: index must be in range [0, size())
T& at(size_t index) {
    return data[index];
}

// BANNED in Stoic (undocumented UB)
const T& front() const {
    return container.front();  // UB if empty!
}

// Stoic: Document UB risk
// UB: calling front() on empty container is undefined behavior
const T& front() const {
    return container.front();
}
```

**Why this matters for AI:**
- AI cannot infer preconditions from code alone
- AI often generates calls without checking preconditions ("Missing Corner Case" pattern)
- Explicit `// PRECONDITION:` markers make constraints visible in context
- Explicit `// UB:` markers prevent AI from assuming safety

**Comment markers:**
- `// PRECONDITION:` — documents what must be true before calling a function
- `// UB:` — documents where undefined behavior can occur if misused

**Enforcement:**
- Code review: All functions with preconditions or potential UB must be documented
- No automated enforcement: Semantic analysis required

### Additional Comment Markers

Beyond the five core rules, Stoic defines additional comment markers for patterns that AI frequently misunderstands. These markers make implicit C++ behaviors explicit.

#### `// MAP_ACCESS:` — Intentional Map Insertion

`std::map::operator[]` has two behaviors: if the key exists, it returns a reference; if missing, it **inserts a default-constructed value**. AI often confuses this with `.at()` (throws) or `.find()` (safe lookup).

```cpp
// BANNED in Stoic (silent insertion)
auto value = myMap[key];  // Inserts default if key missing!

// Stoic: Use .find() or .at() for reads
auto it = myMap.find(key);
if (it != myMap.end()) {
    auto value = it->second;
}

// Stoic: Document intentional insertion
myMap[key] = newValue;  // MAP_ACCESS: intentional insertion/update
```

#### `// COPY:` — Intentional Pass-by-Value

AI often chooses inconsistently between pass-by-value and pass-by-reference. When a function intentionally copies its argument (e.g., for rollback semantics), document it.

```cpp
// AI might "optimize" this to const& — breaking the rollback semantics
// COPY: State copied intentionally for rollback on failure
Result tryOperation(State state) {
    state.modify();
    if (failed()) {
        return Error;  // Original state unchanged
    }
    return Ok(state);
}
```

#### `// TYPE_LIMIT:` — Numeric Constraints on Type Aliases

Custom type aliases often have implicit numeric limits that AI cannot infer from the code.

```cpp
typedef unsigned char PlanLength;  // TYPE_LIMIT: max 255 steps (0-255)
typedef std::uint8_t PredicateId;  // TYPE_LIMIT: max 255 predicates (0-255)

// AI now knows not to generate plans > 255 steps
```

#### `// PLATFORM:` — Platform-Specific Code

Conditional compilation creates code paths AI cannot reason about. Document which platforms are affected.

```cpp
// PLATFORM: Windows high-resolution timer
#if defined(_MSC_VER)
    using Timer = Runtimes_T_hrc<3>;
#else
    // PLATFORM: POSIX clock_gettime fallback
    using Timer = Runtimes_T_clock_t<3>;
#endif
```

## Scorecard

| Dimension | C++ | Stoic | Improvement |
|-----------|-----|-------|-------------|
| Typing | 4/5 | 4/5 | No change (already strong) |
| Explicit | 2/5 | 4/5 | Modules + no macros = visible code |
| Simplicity | 1/5 | 2/5 | Reduced feature surface |
| Error Handling | 2/5 | 2/5 | Not addressed in this version |
| Ecosystem | 5/5 | 4/5 | Module adoption still growing |
| **Total** | **56/100** | **64/100** | **+8 points** *(theoretical, unvalidated)* |

*Scores are theoretical projections. Stoic's current scope is deliberately minimal; the improvement is modest because only five rules are enforced. Future versions may address implicit conversions and error handling.*

**Bug Pattern Prevention** (based on Tambon et al., 2025):

| Stoic Rule | Prevents Bug Pattern |
|------------|---------------------|
| Smart pointers only | "Missing Corner Case" (resource leaks) |
| No macros | "Misinterpretations" (invisible substitution) |
| Modules over headers | "Wrong Attribute" (hidden dependencies) |
| Document preconditions | "Missing Corner Case" (unchecked calls) |
| Document UB | "Missing Corner Case," "Wrong Attribute" (UB triggers) |
| Document map access | "Missing Corner Case" (silent insertion) |
| Document copies | "Misinterpretations" (unintended optimization) |
| Document type limits | "Wrong Input Type" (overflow) |
| Document platforms | "Wrong Attribute" (platform mismatch) |

## Files in This Directory

- `.clang-tidy` — Ready-to-copy linter configuration
- `prompt.md` — AI system prompt template
- `examples/before.cpp` — Common AI mistakes in C++
- `examples/after.cpp` — Stoic-compliant versions

## Known AI Hazards (Practitioner Feedback)

The following patterns are documented AI stumbling points based on practitioner feedback. They are not yet formalized as Stoic rules pending further validation, but developers should be aware of them.

### `std::move` Semantics

AI struggles with move semantics, frequently generating use-after-move bugs and pessimizing moves.

| Problem | AI Behavior |
|---------|-------------|
| Use-after-move | AI accesses objects after `std::move()` |
| Pessimizing return | AI adds `std::move` on return statements, preventing RVO |
| Unnecessary moves | AI moves temporaries that are already rvalues |
| Moved-from state | AI assumes moved objects are still fully valid |

```cpp
// AI generates this — BUG: use-after-move
std::string name = "hello";
container.add(std::move(name));
std::cout << name;  // Undefined behavior! name is moved-from

// AI generates this — WRONG: prevents Return Value Optimization
std::string getName() {
    std::string result = "hello";
    return std::move(result);  // Pessimization! Just return result;
}
```

**Guidance:** Prefer copies unless profiling shows a bottleneck. When using `std::move`, never access the moved-from object afterward.

### Lock-Free Multithreading

AI frequently misunderstands atomic operations and memory ordering. Practitioners report avoiding lock-free code with AI entirely.

| Problem | AI Behavior |
|---------|-------------|
| Memory ordering | AI uses `memory_order_relaxed` incorrectly |
| Non-atomic compounds | AI forgets compare-and-swap must be atomic |
| Fence placement | AI adds fences randomly or omits them |
| ABA problem | AI doesn't understand compare-and-swap pitfalls |

```cpp
// AI generates this — RACE CONDITION
std::atomic<int> counter{0};
if (counter.load() == expected) {  // NOT atomic with the store!
    counter.store(new_value);
}
// Should use: counter.compare_exchange_strong(expected, new_value)

// AI generates this — WRONG memory order
data = prepare_data();
ready.store(true, std::memory_order_relaxed);  // Other thread may see ready before data!
// Should use: ready.store(true, std::memory_order_release);
```

**Guidance:** Use `std::mutex` and `std::lock_guard` first. Lock-free code requires expert review regardless of whether AI generated it.

## Future Rules (Not Yet Included)

The following patterns are known AI stumbling points but are not yet part of Stoic:

| Pattern | Issue | Potential Rule |
|---------|-------|----------------|
| Implicit conversions | AI generates narrowing conversions | Require explicit casts |
| Exception safety | AI forgets RAII in exception paths | Require RAII wrappers |
| `reinterpret_cast` | Type punning bugs | Ban entirely |
| `const` correctness | AI omits `const` | Require `const` by default |
| `std::move` misuse | Use-after-move, pessimizing moves | Document moved-from state |
| Lock-free concurrency | Memory ordering errors | Ban or require expert review |

## Learn More

See the full [Amphigraphic Language Guide](../Amphigraphic_Language_Guide.md) for the complete rationale and methodology.
