# Stoic AI System Prompt

Add this to your AI assistant's system prompt when working with C++ code.

---

## System Prompt Addition

```
When writing C++, follow Stoic (strict C++) rules:

1. PREFER C++20 modules over #include when available
2. NEVER use raw `new`/`delete` - always use std::make_unique or std::make_shared
3. USE std::unique_ptr for sole ownership, std::shared_ptr only when truly shared
4. USE raw pointers (T*) only for non-owning references, never for ownership
5. NEVER define function-like macros - use inline functions or templates
6. NEVER define constant macros - use const variables
7. ONLY allowed macros: include guards, #pragma once, platform/feature detection
8. NEVER add constexpr speculatively - use const by default
9. USE constexpr ONLY when compile-time is REQUIRED: template args, static_assert, if constexpr
10. DOCUMENT preconditions with `// PRECONDITION:` and UB risks with `// UB:`
11. DOCUMENT intentional patterns: `// MAP_ACCESS:`, `// COPY:`, `// TYPE_LIMIT:`, `// PLATFORM:`
```

---

## Extended Version (for complex projects)

```
When writing C++, follow Stoic (strict C++) rules:

MODULES AND HEADERS:
- PREFER `import std;` over individual #include directives (C++20)
- PREFER `import module_name;` over #include "header.h" (C++20)
- IF using headers, ensure each is self-contained with #pragma once
- NEVER rely on transitive includes - include/import what you use

MEMORY MANAGEMENT:
- NEVER use raw `new` - use std::make_unique<T>() instead
- NEVER use raw `delete` - let smart pointers handle cleanup
- NEVER use malloc/calloc/realloc/free - use containers or smart pointers
- USE std::unique_ptr<T> as the default for heap allocation
- USE std::shared_ptr<T> only when ownership is genuinely shared
- USE raw pointers (T*) or references (T&) only for non-owning access
- PREFER value semantics and std::vector over heap allocation when possible

PREPROCESSOR:
- NEVER define function-like macros - use inline functions or templates
- NEVER define constant macros - use const variables
- NEVER use token pasting (##) or stringification (#)
- ONLY allowed: include guards, #pragma once, #ifdef _WIN32, #if __cplusplus >= N
- USE if constexpr instead of #ifdef for compile-time branching on logic

CONSTEXPR (USE SPARINGLY):
- PREFER const over constexpr for constants - simpler, fewer edge cases
- PREFER inline functions over constexpr functions - compiler optimizes anyway
- USE constexpr ONLY when compile-time evaluation is REQUIRED:
  - Template arguments: std::array<T, N> requires N to be constexpr
  - static_assert conditions
  - if constexpr conditions
- NEVER add constexpr speculatively - it causes compilation failures
- NEVER use constexpr with std::string, std::vector, or file I/O (pre-C++20)

OWNERSHIP CLARITY:
- DOCUMENT ownership in comments when passing raw pointers
- USE gsl::not_null<T*> or references when null is not valid
- PREFER returning by value or std::optional over returning raw pointers
- USE std::span<T> for non-owning views of contiguous data

COMMENTS:
- ADD `// OWNERSHIP:` comments when ownership transfer occurs
- ADD `// BORROW:` comments for non-owning pointer parameters
- ADD `// SAFETY:` comments near allowed #ifdef blocks
- ADD `// PRECONDITION:` comments documenting function preconditions
- ADD `// UB:` comments where undefined behavior can occur if misused
- ADD `// MAP_ACCESS:` comments when using operator[] for intentional insertion
- ADD `// COPY:` comments when pass-by-value is intentional (e.g., rollback semantics)
- ADD `// TYPE_LIMIT:` comments documenting numeric constraints of type aliases
- ADD `// PLATFORM:` comments documenting platform-specific conditional compilation
```

---

## Usage Examples

### Claude / Claude Code
Add to your `.claude` or system prompt configuration.

### Cursor
Add to `.cursorrules` in your project root.

### GitHub Copilot
Add to your repository's `.github/copilot-instructions.md`.

### Other AI Assistants
Add to the system prompt or project-level AI configuration file.
