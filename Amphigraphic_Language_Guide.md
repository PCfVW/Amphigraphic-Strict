# Amphigraphic Language Guide
*A Practical Guide to Language Selection for AI-Assisted Development*

**Eric Jacopin & Claude Opus 4.5**  
*January 2026*

---

**Amphigraphic** (from Greek *ἀμφί* [amphi] = "both ways" + *γραφή* [graphē] = "writing"): development that flows in both directions between representations.

Amphigraphic development—the practice of maintaining consistency across specifications, code, and tests using AI transformations—depends on accurate bidirectional code generation and comprehension. This guide identifies which languages best support these transformations.

---

## Table of Contents

1. [Concrete AI Failure Modes (With Examples)](#1-concrete-ai-failure-modes-with-examples)
2. [Required Properties for AI-Optimal Languages](#2-required-properties-for-ai-optimal-languages)
3. [Language Scorecard](#3-language-scorecard)
4. [Actionable Recommendations](#4-actionable-recommendations)
5. [Quick Start: Best Practices Template](#5-quick-start-best-practices-template)
6. [AI Writing Code: Generation Pitfalls & Prevention](#6-ai-writing-code-generation-pitfalls--prevention)
7. [AI Reading Code: Comprehension Pitfalls & Prevention](#7-ai-reading-code-comprehension-pitfalls--prevention)
8. [Quick Reference: Hardening for Both Directions](#8-quick-reference-hardening-for-both-directions)
9. [Conclusion: The AI Accuracy Equation](#9-conclusion-the-ai-accuracy-equation)
10. [References](#references)
11. [Appendix A: Cog — A Strict Go for AI-Assisted Development](#appendix-a-cog--a-strict-go-for-ai-assisted-development)
12. [Appendix B: Grit — A Strict Rust for AI-Assisted Development](#appendix-b-grit--a-strict-rust-for-ai-assisted-development)
13. [Appendix C: Terse — A Strict TypeScript for AI-Assisted Development](#appendix-c-terse--a-strict-typescript-for-ai-assisted-development)
14. [Note on Kotlin](#note-on-kotlin)

---

## Abstract

**The Problem:** AI coding assistants predict "most likely" code from patterns, but many languages allow multiple valid interpretations for the same intent. When the AI guesses wrong, you get subtle bugs that compile but fail at runtime.

**What This Document Covers:** We analyze concrete failure modes across languages (including C++, Python, JavaScript), identify the language properties that research suggests minimize AI errors, propose a scoring framework for current languages with ecosystem factors, and provide actionable fixes for both AI *writing* code (generation) and AI *reading* code (comprehension).

**Why Read This:** Despite growing reliance on AI coding assistants, no head-to-head empirical study has yet compared AI code generation accuracy across programming languages. This guide fills that gap with a *practical framework*—grounded in documented failure modes and supported by adjacent research on type systems and LLM bugs—rather than waiting for perfect data.

By the end, you'll have (1) a proposed scoring framework to evaluate any language's AI-friendliness, (2) concrete patterns to harden your current stack, and (3) specific prompts that prevent the most common AI mistakes in Go, Kotlin, Rust, and TypeScript. The appendices introduce three experimental "strict" subsets—**Cog** (Go), **Grit** (Rust), and **Terse** (TypeScript)—designed to push AI accuracy higher by eliminating ambiguity. These subsets are enforceable today with existing linters.

We offer this as a starting point for practitioners and researchers alike. The framework is falsifiable: if your experience contradicts our recommendations, we want to know.

---

## 1. Concrete AI Failure Modes (With Examples)

### 1.1 Type Ambiguity Failures

| Language | Code | AI Mistake | Root Cause |
|----------|------|------------|------------|
| Python | `def process(data):` | Assumes `data` is list when it's dict | No type annotation, AI guesses from name |
| JavaScript | `user.id + 1` | Generates string concat instead of math | `id` could be string or number |
| Ruby | `config[:timeout] * 2` | Misses `nil` case | Symbol keys return `nil` silently |

**Why it happens:** AI models predict "most likely" code. Without type constraints, multiple interpretations are equally valid statistically.

### 1.2 Implicit Behavior Failures

```python
# Python: AI often forgets default mutable arguments
def append_to(item, target=[]):  # BUG: shared list
    target.append(item)
    return target
```

```javascript
// JavaScript: AI mishandles `this` binding
const handler = obj.method;  // AI forgets `this` is now undefined
button.onClick(handler);
```

```ruby
# Ruby: AI can't predict method_missing behavior
user.namee  # Typo might call method_missing, not raise error
```

**Why it happens:** AI learns surface patterns. Implicit runtime behavior isn't visible in code text.

### 1.3 Build/Environment Complexity

```rust
// Rust: AI suggests code requiring unstable features
#![feature(generic_const_exprs)]  // Only works on nightly
```

```cpp
// C++: AI mixes standard versions
auto result = std::ranges::filter(v, pred);  // C++20 only
std::optional<int> x;  // C++17
```

**Why it happens:** Training data mixes library/language versions. AI can't reliably track compatibility.

### 1.4 Hidden Control Flow

```java
// AI misses that this throws
@Transactional
public void save(User u) {
    repo.save(u);  // RuntimeException rolls back silently
}
```

```python
# AI doesn't anticipate generator exhaustion
data = (x for x in source)
list(data)  # Works
list(data)  # Empty! AI often reuses exhausted generators
```

---

## 2. Required Properties for AI-Optimal Languages

### Tier 1: Critical (Non-Negotiable)

| Property | Why AI Needs It | Test Question | Best-in-Class |
|----------|-----------------|---------------|---------------|
| **Static typing with inference** | Constrains valid completions | Can the compiler catch `"5" + 1`? | **Rust** (strongest guarantees) |
| **Explicit over implicit** | Reduces hidden states AI misses | Are there default mutable values? | **Go** (no hidden magic) |
| **Single obvious way** | Reduces prediction entropy | How many ways to iterate a list? | **Go** (one `for` loop, that's it) |
| **No runtime metaprogramming** | Code text = runtime behavior | Can methods appear at runtime? | **Rust** (no reflection) |

### Tier 2: Important

| Property | Benefit | Example | Best-in-Class |
|----------|---------|---------|---------------|
| **Algebraic data types** | AI models exhaustive matching well | `Result<T,E>` vs exceptions | **Rust** / **OCaml** (native ADTs) |
| **Immutability default** | Eliminates mutation tracking errors | `val` vs `var` distinction | **Rust** (`let` immutable by default) |
| **Explicit error handling** | AI can't forget error paths | `?` operator vs silent nulls | **Rust** (`Result<T,E>` + `?`) |
| **Minimal syntax** | Smaller grammar = better completion | Keyword count < 50 | **Go** (25 keywords) |

### Tier 3: Nice-to-Have

| Property | Benefit | Best-in-Class |
|----------|---------|---------------|
| **First-class LSP/tooling** | AI can query types in real-time | **Rust** (rust-analyzer) |
| **Opinionated formatter** | Consistent training data | **Go** (gofmt, zero config) |
| **Small standard library** | Less API surface to memorize | **Go** (minimal by design) |

### Tier Summary

Rust dominates on correctness properties (Tier 2), while Go dominates on simplicity and tooling (Tier 3). They split evenly on the critical foundations (Tier 1). Kotlin doesn't win any single category but scores 4+ stars across all dimensions.

This data supports a nuanced recommendation:
- **Go** if your AI workflow is "generate fast, iterate quickly" (simplicity reduces friction)
- **Rust** if your AI workflow is "generate once, must be correct" (type system catches more bugs)
- **Kotlin** if you need balance across all dimensions with JVM ecosystem access

---

## 3. Language Scorecard

### 3.1 Results

Each star = 4 points. Maximum = 25 stars (100 points). For scoring criteria, see [§3.2 Scoring Rubric](#32-scoring-rubric).

> **Note:** This scoring framework is *proposed* based on practical engineering experience and the failure modes documented in Sections 1 and 6-7. The criteria reflect properties that research suggests improve AI code generation (see [References](#references)), but direct empirical validation comparing AI accuracy across all listed languages remains an open research opportunity. We welcome feedback and contrary evidence.

| Language | Typing | Explicit | Simplicity | Error Handling | Ecosystem | Stars | **AI Score** |
|----------|--------|----------|------------|----------------|-----------|-------|--------------|
| **Go** | ★★★★☆ | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★★☆ | 21 | 84/100 |
| **Kotlin** | ★★★★★ | ★★★★☆ | ★★★★☆ | ★★★★☆ | ★★★★☆ | 21 | 84/100 |
| **Rust** | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★★★ | ★★★☆☆ | 21 | 84/100 |
| **OCaml/F#** | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★★★ | ★★☆☆☆ | 20 | 80/100 |
| **TypeScript** | ★★★★☆ | ★★★☆☆ | ★★★★☆ | ★★★☆☆ | ★★★★★ | 19 | 76/100 |
| **Python** | ★★★☆☆ | ★★☆☆☆ | ★★★★☆ | ★★☆☆☆ | ★★★★★ | 16 | 64/100 |
| **C++** | ★★★★☆ | ★★☆☆☆ | ★☆☆☆☆ | ★★☆☆☆ | ★★★★★ | 14 | 56/100 |
| **JavaScript** | ★☆☆☆☆ | ★☆☆☆☆ | ★★★☆☆ | ★☆☆☆☆ | ★★★★★ | 11 | 44/100 |

**Key insights:**
- **Go, Kotlin, and Rust** tie for #1 with different strengths—Go on simplicity, Kotlin on balance, Rust on correctness
- **Kotlin** has *no major weaknesses* (4+ stars everywhere), making it the "well-rounded athlete"
- **OCaml/F#** scores high on correctness but loses points on ecosystem reach
- **TypeScript** benefits from the massive JS ecosystem but loses points on explicitness (`any`, type assertions)
- **C++ scores below Python**—strong typing can't compensate for extreme complexity
- **Python/JavaScript** remain low despite huge ecosystems—ecosystem can't fix fundamental AI ambiguity

---

### 3.2 Scoring Rubric

This rubric defines the *proposed* criteria for each star level, derived from the properties identified in Section 2 and validated against the research in [References](#references). Use it to score languages not listed above or to challenge our assessments.

#### Typing (Static Type System Strength)

| Stars | Criteria |
|-------|----------|
| ★★★★★ | Full static typing, strong inference, algebraic data types, **no escape hatches** (no `any`, `Object`, or runtime type erasure) |
| ★★★★☆ | Full static typing with inference, but escape hatches exist (`any`, `interface{}`, `Object`) even if discouraged |
| ★★★☆☆ | Gradual/optional typing available; type hints exist but aren't enforced at compile time |
| ★★☆☆☆ | Limited type annotations exist but no compile-time enforcement; runtime checking only |
| ★☆☆☆☆ | Dynamic typing with no static analysis path; types exist only as documentation |

**Test:** "If I annotate all types, can the compiler catch `"5" + 1` as an error?"

---

#### Explicitness (Absence of Implicit Behaviors)

| Stars | Criteria |
|-------|----------|
| ★★★★★ | No implicit conversions, no default mutable arguments, no magic methods, no runtime metaprogramming, no implicit `this` binding |
| ★★★★☆ | Minimal implicit behavior; one or two edge cases exist (e.g., Go's typed nil, Kotlin's platform types) |
| ★★★☆☆ | Some implicit conversions or behaviors that are well-documented and predictable |
| ★★☆☆☆ | Multiple implicit behaviors (coercions, default arguments, `this` binding) that frequently surprise developers |
| ★☆☆☆☆ | Extensive implicit behavior: runtime metaprogramming, monkey patching, implicit coercions are common patterns |

**Test:** "Can a function's behavior change based on something not visible in its signature or body?"

---

#### Simplicity (Cognitive Load / Grammar Size)

| Stars | Criteria |
|-------|----------|
| ★★★★★ | <30 keywords, one obvious way to do common tasks (iteration, error handling), minimal syntax variation |
| ★★★★☆ | <50 keywords, mostly one way to do things but some alternatives exist |
| ★★★☆☆ | <75 keywords, multiple valid approaches to common tasks, moderate syntax surface area |
| ★★☆☆☆ | Large grammar, multiple paradigms coexist (OOP + FP + procedural), significant syntax to learn |
| ★☆☆☆☆ | Massive grammar (100+ keywords or equivalent complexity), decades of accumulated features, multiple ways to do everything |

**Test:** "How many distinct ways can you write a loop over a collection?"

---

#### Error Handling (Explicit, Compiler-Enforced Error Paths)

| Stars | Criteria |
|-------|----------|
| ★★★★★ | Errors are types (`Result<T,E>`), compiler enforces handling, no unchecked exceptions, errors cannot be silently ignored |
| ★★★★☆ | Errors are explicit and idiomatic (multiple return values, nullable types), but can be ignored without compiler warning |
| ★★★☆☆ | Mix of explicit errors and exceptions; best practice is explicit but exceptions are common |
| ★★☆☆☆ | Exception-based error handling is primary; errors can propagate silently through call stack |
| ★☆☆☆☆ | No structured error handling; errors return as magic values (`-1`, `null`) or silent failures |

**Test:** "If a function can fail, does the compiler force the caller to acknowledge it?"

---

#### Ecosystem (Tooling, Libraries, AI Training Data)

| Stars | Criteria |
|-------|----------|
| ★★★★★ | Massive library ecosystem, extensive AI training data, first-class LSP, opinionated formatter, strong IDE support |
| ★★★★☆ | Large ecosystem, good tooling, substantial AI training data, active community |
| ★★★☆☆ | Moderate ecosystem, adequate tooling, some gaps in library coverage or AI familiarity |
| ★★☆☆☆ | Small but functional ecosystem, limited AI training exposure, basic tooling |
| ★☆☆☆☆ | Niche language, minimal libraries, poor tooling, AI rarely trained on this code |

**Test:** "If I ask an AI to use a common library in this language, will it know the current API?"

---

## 4. Actionable Recommendations

### Decision Tree: Pick Your Language

```
START
  │
  ├─► Need JS ecosystem? ──► TypeScript (strict mode)
  │
  ├─► Need JVM ecosystem? ──► Kotlin
  │
  ├─► Performance critical? ──► Rust (accept learning curve)
  │
  ├─► Team velocity priority? ──► Go (simplicity wins)
  │
  └─► Correctness critical? ──► Rust or OCaml/F#
```

### Immediate Actions by Current Stack

| If you use... | Do this today | Expected AI improvement |
|---------------|---------------|------------------------|
| **Python** | Add type hints everywhere, use `mypy --strict` | Significant reduction in type-related errors |
| **JavaScript** | Migrate to TypeScript strict mode | Major reduction in ambiguity errors |
| **Java** | Migrate to Kotlin, or enable `@NonNull` annotations | Moderate improvement in null handling |
| **Ruby** | Add Sorbet/RBS type signatures | Significant reduction in type errors |
| **Go** | Adopt Cog rules (Appendix A) | Fewer error-handling and nil-related bugs |
| **Rust** | Adopt Grit rules (Appendix B) | Fewer lifetime and conversion errors |
| **TypeScript** | Adopt Terse rules (Appendix C) | Fewer type-escape and narrowing bugs |
| **Any language** | Use explicit return types on all functions | Noticeable improvement across the board |

### Configuration Checklist

```yaml
# .cursorrules / AI assistant config pattern
rules:
  - "Always use explicit types, never `any` or `Object`"
  - "Prefer immutable data structures"
  - "Use Result/Option types instead of null"
  - "No magic methods or metaprogramming"
  - "One statement per line, no chained mutations"
```

For language-specific rules, see the AI prompt templates in Appendices A (Cog), B (Grit), and C (Terse).

---

## 5. Quick Start: Best Practices Template

### For TypeScript (JS Ecosystem)

```typescript
// ✅ AI-friendly: explicit, constrained, predictable
type UserId = string & { readonly brand: unique symbol };

interface User {
  readonly id: UserId;
  readonly email: string;
  readonly createdAt: Date;
}

function getUser(id: UserId): Promise<User | null> {
  // AI knows exact return type, can't confuse with throw
}

// ❌ AI-hostile: implicit, ambiguous
function getUser(id) {
  // AI guesses types, might assume throws on not-found
}
```

### For Go (Simplest Mental Model)

```go
// ✅ AI-friendly: one way to do things, explicit errors
func GetUser(id string) (User, error) {
    // AI always generates error handling
}

// Structs with explicit zero values
type Config struct {
    Timeout time.Duration // Zero = 0, explicit
    Retries int           // Zero = 0, explicit
}
```

### For Kotlin (JVM Ecosystem)

```kotlin
// ✅ AI-friendly: null safety built-in, explicit types
data class User(
    val id: String,
    val email: String,
    val createdAt: Instant
)

fun getUser(id: String): User? {
    // AI knows this returns nullable, must handle null
}

// ✅ AI-friendly: sealed classes for exhaustive matching
sealed class Result<out T> {
    data class Success<T>(val value: T) : Result<T>()
    data class Failure(val error: Throwable) : Result<Nothing>()
}

fun fetchUser(id: String): Result<User> {
    // AI generates proper when() exhaustive checks
}

// ❌ AI-hostile: platform types from Java interop
fun processJavaData(data: JavaObject) {
    data.field  // AI doesn't know if this is nullable!
}
```

### For Rust (Maximum Correctness)

```rust
// ✅ AI-friendly: explicit types, Result for errors
fn get_user(id: &str) -> Result<User, DbError> {
    // AI generates proper ? propagation
}

// ✅ AI-friendly: explicit lifetimes
fn get_name<'a>(&'a self) -> &'a str {
    &self.name  // AI knows borrow relationship
}

// ❌ AI-hostile: implicit lifetimes, unwrap
fn get_name(&self) -> &str { ... }  // Which lifetime?
let user = find_user(id).unwrap();   // AI forgets error handling
```

---

## 6. AI Writing Code: Generation Pitfalls & Prevention

When AI generates code, it predicts "most likely" patterns—which often include subtle bugs. Here's what it gets wrong and how to prevent it.

### 6.1 Go Generation Failures

| Bug AI Generates | Example | Prevention Strategy |
|------------------|---------|---------------------|
| **Missing loop variable capture** | `go func() { process(i) }()` | Prompt: "Always pass loop variables as goroutine arguments" |
| **Typed nil returned as interface** | `return err` where `err` is `*MyError(nil)` | Prompt: "Return explicit `nil` for interface types, never typed nil pointers" |
| **Nil slice instead of empty** | `var results []Item` then JSON encode | Prompt: "Use `make([]T, 0)` when the result will be serialized" |

**System prompt addition for Go:**
```
When writing Go:
- Pass loop variables to goroutines as arguments: go func(x T) {...}(x)
- Return bare `nil`, never typed nil, for interface return types
- Initialize slices with make([]T, 0) when they may be JSON-encoded
- Always check errors immediately after the call that produces them
```

### 6.2 Rust Generation Failures

| Bug AI Generates | Example | Prevention Strategy |
|------------------|---------|---------------------|
| **Wrong lifetime inference** | `fn get(&self) -> &str` borrowing from wrong source | Prompt: "Use explicit lifetime annotations on all public functions" |
| **Implicit deref in wrong context** | Passing `&String` where ownership needed | Prompt: "Use explicit `.as_str()`, `.clone()`, `.to_owned()` conversions" |
| **Async without owned data** | `async fn process(&self)` causing lifetime errors | Prompt: "Async functions should take owned types, not references" |

**System prompt addition for Rust:**
```
When writing Rust:
- Add explicit lifetimes to any function returning references
- Use .clone() or .to_owned() explicitly rather than relying on deref coercion
- Prefer owned types (String, Vec<T>) over references in async function signatures
- Use `async move` blocks when capturing variables
```

### 6.3 TypeScript Generation Failures

| Bug AI Generates | Example | Prevention Strategy |
|------------------|---------|---------------------|
| **Stale narrowing after await** | `if (x) { await op(); x.foo }` | Prompt: "Assign narrowed values to const before any await" |
| **Wrong spread order** | `{...overrides, ...defaults}` negating overrides | Prompt: "Add comment showing merge priority: `// defaults < overrides`" |
| **Missing index safety** | `arr[i].value` without undefined check | Prompt: "Always use optional chaining for array index access: `arr[i]?.value`" |

**System prompt addition for TypeScript:**
```
When writing TypeScript:
- After type narrowing, assign to a const before any await
- Comment object spread order: // base < overrides (last wins)
- Use optional chaining for all array/object index access
- Never use `any`, `as` casts, or non-null assertions (!)
```

### 6.4 Kotlin Generation Failures

| Bug AI Generates | Example | Prevention Strategy |
|------------------|---------|---------------------|
| **Platform type unsafety** | `javaObject.field.method()` without null check | Prompt: "Treat all Java interop as nullable unless annotated" |
| **Scope function confusion** | Mixing `let`, `run`, `apply`, `also` incorrectly | Prompt: "Use `let` for null checks, `apply` for configuration, avoid `run`" |
| **Coroutine scope leaks** | `GlobalScope.launch` instead of structured concurrency | Prompt: "Never use GlobalScope, always use coroutineScope or viewModelScope" |

**System prompt addition for Kotlin:**
```
When writing Kotlin:
- Treat ALL Java interop types as nullable - add `?` and null checks
- Use `let` for null-safe operations: value?.let { process(it) }
- Use `apply` only for object configuration: Builder().apply { setX(1) }
- NEVER use GlobalScope - use structured concurrency (coroutineScope, supervisorScope)
- Prefer sealed classes over enums for state modeling
- Use data classes for all DTOs with val properties only
```

---

## 7. AI Reading Code: Comprehension Pitfalls & Prevention

When AI reads/analyzes existing code, it misses implicit behaviors not visible in syntax. Here's what it overlooks and how to make your code AI-readable.

### 7.1 Go Comprehension Failures

| What AI Misses | Why | How to Make Code AI-Readable |
|----------------|-----|------------------------------|
| **Goroutine variable capture bugs** | Closure semantics invisible in syntax | Add comment: `// captured by value` or refactor to explicit argument |
| **Interface nil vs typed nil** | `err != nil` behavior depends on concrete type | Add comment: `// returns interface nil, not *ConcreteType nil` |
| **Slice nil vs empty semantics** | Both have `len() == 0` | Use explicit initialization and comment: `// empty slice, not nil (for JSON)` |

**Code patterns that help AI understand Go:**
```go
// ✅ AI-readable: explicit capture
for _, item := range items {
    item := item  // CAPTURE: loop variable copied for goroutine
    go func() {
        process(item)
    }()
}

// ✅ AI-readable: nil intent documented
func findUser(id string) (User, error) {
    if id == "" {
        return User{}, nil  // NOT FOUND: returns zero value, nil error (not typed nil)
    }
    // ...
}

// ✅ AI-readable: slice initialization intent
results := make([]Item, 0)  // EMPTY SLICE: will marshal to [] not null
```

### 7.2 Rust Comprehension Failures

| What AI Misses | Why | How to Make Code AI-Readable |
|----------------|-----|------------------------------|
| **Elided lifetime relationships** | `fn get(&self) -> &str` hides borrow source | Add explicit lifetimes: `<'a>(&'a self) -> &'a str` |
| **Deref coercion chain** | `&String` silently becomes `&str` | Add type annotations at coercion points |
| **Drop order significance** | Destructor order affects correctness | Comment: `// drop order: x before y (required for cleanup)` |

**Code patterns that help AI understand Rust:**
```rust
// ✅ AI-readable: explicit lifetime shows relationship
impl<'a> Parser<'a> {
    // Lifetime 'a shows return borrows from self.input, not self
    fn next_token(&self) -> &'a str {
        &self.input[self.pos..self.end]
    }
}

// ✅ AI-readable: explicit conversion, not implicit deref
fn process(input: &str) {
    let s: String = input.to_owned();  // OWNED: explicit conversion from &str
    let bytes: &[u8] = input.as_bytes();  // BORROW: explicit conversion to bytes
}

// ✅ AI-readable: drop order documented
struct Connection {
    writer: BufWriter<TcpStream>,  // DROP SECOND: flush before stream closes
    stream: TcpStream,              // DROP FIRST: closes connection
}
// Note: fields drop in declaration order (top to bottom)
```

### 7.3 TypeScript Comprehension Failures

| What AI Misses | Why | How to Make Code AI-Readable |
|----------------|-----|------------------------------|
| **Narrowing invalidation** | Await/callbacks reset type guards invisibly | Assign narrowed value to clearly named const |
| **Spread evaluation order** | `{...a, ...b}` priority not obvious | Destructure explicitly or add comment |
| **Index signature unsafety** | `obj[key]` might be undefined despite types | Use explicit undefined checks |

**Code patterns that help AI understand TypeScript:**
```typescript
// ✅ AI-readable: narrowing captured in named variable
async function processUser(user: User | null) {
    if (!user) return;
    
    const validUser = user;  // NARROWED: captured before async boundary
    await someOperation();
    
    // AI sees validUser is definitely User, not re-checking user
    console.log(validUser.name);
}

// ✅ AI-readable: merge order explicit
const config = {
    ...defaults,    // PRIORITY 1: base values
    ...userPrefs,   // PRIORITY 2: user overrides defaults  
    ...required,    // PRIORITY 3: required overrides everything
};

// ✅ AI-readable: index access safety explicit
function getItem(items: Item[], index: number): Item | undefined {
    const item = items[index];  // MAYBE UNDEFINED: index could be out of bounds
    if (!item) return undefined;
    return item;
}
```

### 7.4 Kotlin Comprehension Failures

| What AI Misses | Why | How to Make Code AI-Readable |
|----------------|-----|------------------------------|
| **Platform type nullability** | Java interop hides nullability | Add explicit `?` types and `// NULLABLE` comments on Java calls |
| **Scope function receiver** | `this` vs `it` varies by function | Use parameter names: `user.let { u -> u.name }` not `user.let { it.name }` |
| **Coroutine context inheritance** | Dispatchers inherited implicitly | Add explicit dispatcher: `withContext(Dispatchers.IO) { }` |

**Code patterns that help AI understand Kotlin:**
```kotlin
// ✅ AI-readable: explicit nullability on Java interop
val name: String? = javaUser.getName()  // NULLABLE: Java method, assume null possible
if (name != null) {
    process(name)  // Smart cast to String
}

// ✅ AI-readable: named parameter in scope functions
user?.let { validUser ->  // NAMED: clearer than 'it'
    repository.save(validUser)
}

// ✅ AI-readable: explicit coroutine context
suspend fun fetchData(): Data {
    return withContext(Dispatchers.IO) {  // EXPLICIT: IO dispatcher for network
        api.fetch()
    }
}

// ✅ AI-readable: sealed class with exhaustive when
sealed class State {
    object Loading : State()
    data class Success(val data: Data) : State()
    data class Error(val cause: Throwable) : State()
}

fun handle(state: State): String = when (state) {
    is State.Loading -> "Loading..."
    is State.Success -> "Got: ${state.data}"
    is State.Error -> "Error: ${state.cause.message}"
    // No else needed - compiler enforces exhaustiveness
}
```

---

## 8. Quick Reference: Hardening for Both Directions

### Tooling to Catch AI Generation Bugs

| Language | Linters & Flags | Catches |
|----------|-----------------|---------|
| **Go** | `go vet`, `staticcheck`, `golangci-lint` | Loop capture, nil interface, unused errors |
| **Kotlin** | `detekt`, explicit API mode, `@Nullable` annotations | Platform types, unused results, scope abuse |
| **Rust** | `#![deny(elided_lifetimes_in_paths)]`, `clippy::pedantic` | Missing lifetimes, implicit conversions |
| **TypeScript** | `strict`, `noUncheckedIndexedAccess` | Type holes, unsafe index access |

### Code Style Rules for AI Readability

| Language | Always Do | Never Do |
|----------|-----------|----------|
| **Go** | Comment capture semantics, explicit nil returns | Named return values, bare `interface{}` |
| **Kotlin** | Name scope function parameters, explicit dispatchers | `GlobalScope`, implicit platform types |
| **Rust** | Explicit lifetimes on public API, type annotations at conversions | Rely on deref coercion, elide lifetimes in complex functions |
| **TypeScript** | Name narrowed values, comment spread order | Use `any`, rely on implicit narrowing across await |

---

## 9. Conclusion: The AI Accuracy Equation

```
AI Accuracy ∝ f(Type Strictness × Explicitness × Simplicity)
             ÷ (Implicit Behaviors × Metaprogramming × Syntax Variants)
```

**Top picks for new AI-assisted projects:**
1. **Go** — When you want AI to "just work" with minimal setup (84/100)
2. **Kotlin** — When you need JVM ecosystem with balanced AI-friendliness (84/100)
3. **Rust** — When correctness matters more than speed-to-market (84/100)
4. **TypeScript (strict)** — When you need JS ecosystem but want AI reliability (76/100)

**With strict subsets (see Appendices):**
- [**Cog**](#appendix-a-cog--a-strict-go-for-ai-assisted-development) (strict Go) — Eliminates error-handling and nil ambiguity (projected: 96/100)
- [**Terse**](#appendix-c-terse--a-strict-typescript-for-ai-assisted-development) (strict TypeScript) — Eliminates type escape hatches (projected: 92/100)
- [**Grit**](#appendix-b-grit--a-strict-rust-for-ai-assisted-development) (strict Rust) — Makes implicit behaviors explicit (projected: 92/100)

**The single highest-impact change:** Add explicit types to everything. This alone substantially reduces AI errors in any language.

---

## References

The following research informs the claims and recommendations in this guide:

### Type Systems and AI Code Generation

1. **Mündler, N., He, J., Wang, H., Sen, K., Song, D., & Vechev, M.** (2025). "Type-Constrained Code Generation with Language Models." *arXiv:2504.09246*. ETH Zurich & UC Berkeley.
   - Key finding: Type-constrained decoding reduced compiler errors by **74.8%** on HumanEval and **56.0%** on MBPP compared to unconstrained generation.
   - Supports: Section 2's emphasis on static typing as a critical property; the Terse (TypeScript) subset rationale.

### Bug Patterns in LLM-Generated Code

2. **Tambon, F., Moradi Dakhel, A., et al.** (2024). "Bugs in Large Language Models Generated Code: An Empirical Study." *arXiv:2403.08937*.
   - Key finding: Identified 10 distinctive bug patterns including "Wrong Input Type," "Missing Corner Case," "Hallucinated Object," and "Prompt-biased code."
   - Supports: Section 1's concrete failure modes; the rationale for explicit typing and error handling.

3. **Dou, S., et al.** (2024). "What's Wrong with Your Code Generated by Large Language Models? An Extensive Study." *arXiv:2407.06153*.
   - Key finding: LLMs achieve ~41.6% average passing rate; they struggle with complex problems and produce code that is "shorter yet more complicated" than canonical solutions. Developed a 12-category bug taxonomy.
   - Supports: The complexity dimension in our scoring rubric; the value of simplicity (Section 2, Tier 1).

4. **Wang, Z., Zhou, Z., Song, D., et al.** (2024). "Where Do Large Language Models Fail When Generating Code?" *ICSE 2025*.
   - Key finding: Different LLMs exhibit different distributions of semantic and syntactic error characteristics.
   - Supports: The claim that language properties affect AI error patterns differently.

### AI Coding Assistant Productivity

5. **Peng, S., Kalliamvakou, E., Cihon, P., & Demirer, M.** (2023). "The Impact of AI on Developer Productivity: Evidence from GitHub Copilot." *arXiv:2302.06590*.
   - Key finding: Developers with Copilot access completed tasks **55.8% faster** than the control group.
   - Supports: The general premise that AI-assisted development is valuable and worth optimizing for.

6. **Ziegler, A., Kalliamvakou, E., et al.** (2024). "Measuring GitHub Copilot's Impact on Productivity." *Communications of the ACM*, 67(3), 54-63.
   - Key finding: Acceptance rate of suggestions predicts perceived productivity; developers report improved focus and satisfaction.
   - Supports: The value of reducing AI friction through language choice.

### Systematic Reviews

7. **Pinhanez, C., et al.** (2024). "Large Language Models for Code Completion: A Systematic Literature Review." *Computer Standards & Interfaces*.
   - Key finding: LLMs utilizing Transformer algorithms have become dominant for code completion; productivity gains come from reduced cognitive load.
   - Supports: The document's focus on reducing AI prediction ambiguity.

---

## Appendix A: Cog — A Strict Go for AI-Assisted Development

*Cog: a precise mechanical tooth that meshes perfectly—like Go's simplicity, but with zero play.*

Go scores 84/100, but its remaining weaknesses (error handling ★★★☆☆, typing ★★★★☆) cause predictable AI failures. **Cog** is a restricted subset of Go that eliminates these failure modes through enforceable rules.

### A.1 What Cog Provides

| Go Weakness | Cog Rule | AI Benefit |
|-------------|----------|------------|
| Forgotten error checks | All errors must be handled or explicitly ignored | AI can't generate `val, _ := riskyFunc()` silently |
| `any`/`interface{}` type erasure | Banned entirely | AI always knows concrete types |
| Nil interface confusion | Only bare `nil` allowed for interface returns | AI can't generate typed-nil bugs |
| Goroutine capture bugs | Loop variables must be passed as arguments | AI generates safe concurrent code |
| Nil vs empty slice ambiguity | Explicit initialization required | AI knows JSON serialization behavior |
| Named return confusion | Named returns banned | AI generates explicit return statements |
| Bare returns | Banned (must return explicit values) | AI can't generate ambiguous returns |
| Unstructured errors | Must use error wrapping with context | AI generates traceable errors |

### A.2 Cog Rules Reference

#### Rule 1: No Type Erasure
```go
// ❌ BANNED in Cog
func process(data any) any { ... }
func store(items []interface{}) { ... }

// ✅ Cog: Use generics or concrete types
func process[T Processor](data T) Result[T] { ... }
func store[T Item](items []T) { ... }
```

#### Rule 2: Explicit Error Handling
```go
// ❌ BANNED in Cog
result, _ := mightFail()           // Silent ignore
result, err := mightFail()         // err never checked

// ✅ Cog: Handle or explicitly mark as intentionally ignored
result, err := mightFail()
if err != nil {
    return fmt.Errorf("context: %w", err)
}

// ✅ Cog: Explicit ignore with comment
result, err := mightFail()
_ = err  // IGNORE: fallback value acceptable here
```

#### Rule 3: No Named Returns
```go
// ❌ BANNED in Cog
func calculate() (result int, err error) {
    result = 42
    return  // What gets returned? AI gets confused
}

// ✅ Cog: Explicit returns only
func calculate() (int, error) {
    result := 42
    return result, nil  // Crystal clear
}
```

#### Rule 4: Interface Nil Safety
```go
// ❌ BANNED in Cog
func getError() error {
    var err *MyError = nil
    return err  // Non-nil interface with nil value!
}

// ✅ Cog: Return bare nil for interfaces
func getError() error {
    if noError {
        return nil  // Always bare nil
    }
    return &MyError{msg: "failed"}
}
```

#### Rule 5: Safe Goroutine Capture
```go
// ❌ BANNED in Cog
for _, item := range items {
    go func() {
        process(item)  // Captures loop variable by reference
    }()
}

// ✅ Cog: Pass as argument
for _, item := range items {
    go func(it Item) {
        process(it)  // Value captured explicitly
    }(item)
}
```

#### Rule 6: Explicit Slice Initialization
```go
// ❌ BANNED in Cog
var results []Item          // nil slice - JSON encodes to null
results := []Item{}         // Inconsistent with above

// ✅ Cog: Always use make for empty slices
results := make([]Item, 0)  // Empty slice - JSON encodes to []
```

#### Rule 7: Result Type Pattern
```go
// Cog standard library addition
type Result[T any] struct {
    value T
    err   error
    ok    bool
}

func Ok[T any](v T) Result[T]       { return Result[T]{value: v, ok: true} }
func Err[T any](e error) Result[T]  { return Result[T]{err: e, ok: false} }
func (r Result[T]) Unwrap() (T, error) {
    if !r.ok { return r.value, r.err }
    return r.value, nil
}

// ✅ Cog: Functions return Result
func fetchUser(id string) Result[User] {
    user, err := db.Find(id)
    if err != nil {
        return Err[User](fmt.Errorf("fetch user %s: %w", id, err))
    }
    return Ok(user)
}
```

### A.3 Enforcing Cog Today

All Cog rules can be enforced with existing tools:

```yaml
# .golangci.yml - Cog configuration
linters:
  enable:
    - errcheck          # Rule 2: no unchecked errors
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - nakedret          # Rule 3: no bare returns
    - nilerr            # Rule 4: nil error handling
    - bodyclose
    - exhaustive        # Exhaustive enum switches

linters-settings:
  nakedret:
    max-func-lines: 0   # Rule 3: ban ALL naked returns
  
  govet:
    enable:
      - loopclosure     # Rule 5: goroutine capture (Go <1.22)

  revive:
    rules:
      - name: bare-return
        disabled: false
      - name: empty-block
        disabled: false

issues:
  exclude-rules:
    # No exclusions - Cog is strict
```

```bash
# Additional checks via staticcheck
staticcheck -checks=all ./...

# Ban interface{}/any via grep (add to CI)
! grep -rn "interface{}\|any" --include="*.go" . | grep -v "_test.go"
```

### A.4 Cog AI Prompt Template

Add to your AI assistant's system prompt:

```
When writing Go, follow Cog (strict Go) rules:
1. NEVER use `any` or `interface{}` - always use generics or concrete types
2. ALWAYS handle errors explicitly - never use `_` to ignore without comment
3. NEVER use named returns - always return explicit values
4. ALWAYS return bare `nil` for interface types, never typed nil
5. ALWAYS pass loop variables as goroutine arguments
6. ALWAYS use `make([]T, 0)` for empty slices, never `var s []T`
7. ALWAYS wrap errors with context: `fmt.Errorf("context: %w", err)`
8. NEVER use bare `return` statements - always `return value, err`
```

### A.5 Cog Scorecard (Projected)

Applying the proposed rubric to Cog yields the following projected improvements:

| Dimension | Go | Cog | Improvement |
|-----------|-----|-----|-------------|
| Typing | ★★★★☆ | ★★★★★ | Generics-only, no type erasure |
| Explicit | ★★★★★ | ★★★★★ | Already excellent |
| Simplicity | ★★★★★ | ★★★★☆ | Slight overhead from Result type |
| Error Handling | ★★★☆☆ | ★★★★★ | Enforced, wrapped, traceable |
| Ecosystem | ★★★★☆ | ★★★★☆ | Same (it's still Go) |
| **Total** | **21 → 84** | **24 → 96** | Projected gain |

### A.6 Migration Path: Go → Cog

| Week | Action | Verification |
|------|--------|--------------|
| 1 | Add `.golangci.yml` with Cog config | CI passes |
| 2 | Fix all `errcheck` violations | Zero unchecked errors |
| 3 | Replace `interface{}`/`any` with generics | `grep` finds zero matches |
| 4 | Eliminate named returns | `nakedret` reports zero |
| 5 | Add Result[T] to common packages | Team trained on pattern |
| 6 | Update AI prompts with Cog rules | Review AI output quality |

**Expected outcome:** Elimination of the error-handling and nil-related failure modes documented in Sections 6-7.

---

## Appendix B: Grit — A Strict Rust for AI-Assisted Development

*Grit: unyielding toughness and determination—Rust's rigor, with no shortcuts allowed.*

Rust scores 84/100, with its main weakness being complexity (★★★☆☆). **Grit** is a restricted subset that makes implicit behaviors explicit, eliminating the patterns where AI stumbles.

### B.1 What Grit Provides

| Rust Weakness | Grit Rule | AI Benefit |
|---------------|-----------|------------|
| Elided lifetimes | Explicit lifetimes on all public APIs | AI knows borrow relationships |
| Deref coercion chains | Explicit conversions required | AI tracks actual types |
| `unwrap()`/`expect()` panics | Banned in library code | AI generates proper error handling |
| `unsafe` blocks | Banned or isolated to marked modules | AI can't generate UB |
| `Box<dyn Any>` type erasure | Banned | AI always knows concrete types |
| Implicit `Drop` ordering | Document or restructure | AI understands cleanup |
| Async lifetime confusion | Owned types in async signatures | AI avoids lifetime errors |
| Catch-all match arms | Exhaustive matching required | AI handles all variants |

### B.2 Grit Rules Reference

#### Rule 1: Explicit Lifetimes
```rust
// ❌ BANNED in Grit (public APIs)
pub fn get_name(&self) -> &str { ... }
pub fn parse(input: &str) -> Option<&str> { ... }

// ✅ Grit: Lifetimes explicit on all public functions
pub fn get_name<'a>(&'a self) -> &'a str { ... }
pub fn parse<'a>(input: &'a str) -> Option<&'a str> { ... }

// ✅ Grit: Private functions may elide (implementation detail)
fn internal_parse(&self) -> &str { ... }  // OK
```

#### Rule 2: Explicit Conversions
```rust
// ❌ BANNED in Grit
fn process(s: &str) { ... }
let string = String::from("hello");
process(&string);  // Implicit Deref coercion

// ✅ Grit: Explicit conversion
process(string.as_str());  // Clear what's happening

// ❌ BANNED in Grit
let bytes: &[u8] = &string;  // Implicit via Deref chain

// ✅ Grit: Explicit conversion
let bytes: &[u8] = string.as_bytes();
```

#### Rule 3: No Panic in Libraries
```rust
// ❌ BANNED in Grit (library code)
let value = map.get(&key).unwrap();
let num: i32 = input.parse().expect("invalid");
let first = vec[0];  // Panics if empty

// ✅ Grit: Propagate errors
let value = map.get(&key).ok_or(Error::NotFound)?;
let num: i32 = input.parse().map_err(Error::Parse)?;
let first = vec.first().ok_or(Error::Empty)?;

// ✅ Grit: Application entry points may use expect with context
fn main() {
    let config = load_config().expect("Failed to load config.toml");
}
```

#### Rule 4: No Type Erasure
```rust
// ❌ BANNED in Grit
fn store(item: Box<dyn Any>) { ... }
fn process(handler: Box<dyn Fn()>) { ... }  // Sometimes OK, see below

// ✅ Grit: Use generics
fn store<T: Item>(item: T) { ... }
fn process<F: Fn()>(handler: F) { ... }

// ✅ Grit: Trait objects OK when genuinely needed (documented)
// TRAIT_OBJECT: Required for heterogeneous collection
fn register(handlers: Vec<Box<dyn Handler>>) { ... }
```

#### Rule 5: Unsafe Isolation
```rust
// ❌ BANNED in Grit (mixed with safe code)
fn process(data: &[u8]) -> Value {
    // ... safe code ...
    unsafe { ptr::read(data.as_ptr() as *const Value) }
    // ... more safe code ...
}

// ✅ Grit: Isolate in dedicated module
// src/unsafe_ops.rs
#![allow(unsafe_code)]
/// SAFETY: Caller must ensure data is valid Value layout
pub unsafe fn transmute_value(data: &[u8]) -> Value { ... }

// src/process.rs
#![forbid(unsafe_code)]
fn process(data: &[u8]) -> Result<Value, Error> {
    validate_layout(data)?;
    // SAFETY: validate_layout ensures correct layout
    Ok(unsafe { unsafe_ops::transmute_value(data) })
}
```

#### Rule 6: Owned Async Signatures
```rust
// ❌ BANNED in Grit
async fn fetch_user(&self, id: &str) -> User { ... }  // Lifetime confusion
async fn process<'a>(&'a self) -> &'a str { ... }     // Complex bounds

// ✅ Grit: Async takes owned types
async fn fetch_user(db: Db, id: String) -> Result<User, Error> { ... }
async fn process(data: String) -> String { ... }

// ✅ Grit: If borrowing needed, use explicit async block
fn fetch_user<'a>(&'a self, id: &'a str) -> impl Future<Output = User> + 'a {
    async move {
        // Explicit capture
    }
}
```

#### Rule 7: Exhaustive Matching
```rust
// ❌ BANNED in Grit
match status {
    Status::Active => handle_active(),
    _ => {}  // What statuses are ignored? AI doesn't know
}

// ✅ Grit: All variants explicit
match status {
    Status::Active => handle_active(),
    Status::Pending => {}      // EXPLICIT: pending needs no action
    Status::Cancelled => {}    // EXPLICIT: cancelled needs no action  
    Status::Expired => {}      // EXPLICIT: expired needs no action
}

// ✅ Grit: If truly exhaustive with remainder, document
match status {
    Status::Active => handle_active(),
    // CATCH_ALL: All inactive statuses handled identically
    Status::Pending | Status::Cancelled | Status::Expired => {}
}
```

### B.3 Enforcing Grit Today

```toml
# Cargo.toml
[lints.rust]
unsafe_code = "forbid"  # Or "deny" with isolated modules
elided_lifetimes_in_paths = "deny"

[lints.clippy]
unwrap_used = "deny"
expect_used = "deny"           # Allow in main/tests only
panic = "deny"
indexing_slicing = "deny"      # Use .get() instead
wildcard_enum_match_arm = "deny"
as_conversions = "warn"        # Explicit From/Into preferred
```

```rust
// lib.rs - Grit crate-level config
#![deny(elided_lifetimes_in_paths)]
#![deny(unsafe_code)]
#![deny(clippy::unwrap_used)]
#![deny(clippy::expect_used)]
#![deny(clippy::wildcard_enum_match_arm)]
```

```bash
# CI check
cargo clippy -- -D warnings
cargo clippy -- -D clippy::pedantic
```

### B.4 Grit AI Prompt Template

```
When writing Rust, follow Grit (strict Rust) rules:
1. ADD explicit lifetimes to all public function signatures
2. USE explicit conversions (.as_str(), .as_bytes(), .to_owned()) instead of relying on Deref
3. NEVER use .unwrap() or .expect() in library code - propagate errors with ?
4. NEVER use Box<dyn Any> - use generics or concrete types
5. ISOLATE unsafe code in dedicated modules with safety comments
6. USE owned types (String, Vec<T>) in async function signatures, not references
7. MATCH all enum variants explicitly - never use _ catch-all without documenting why
8. ANNOTATE type conversions: let x: TargetType = source.into();
```

### B.5 Grit Scorecard (Projected)

Applying the proposed rubric to Grit yields the following projected improvements:

| Dimension | Rust | Grit | Improvement |
|-----------|------|------|-------------|
| Typing | ★★★★★ | ★★★★★ | Same (already excellent) |
| Explicit | ★★★★★ | ★★★★★ | Same (rules reinforce) |
| Simplicity | ★★★☆☆ | ★★★★☆ | Fewer implicit behaviors |
| Error Handling | ★★★★★ | ★★★★★ | Same (already excellent) |
| Ecosystem | ★★★☆☆ | ★★★☆☆ | Same |
| **Total** | **21 → 84** | **23 → 92** | Projected gain |

### B.6 Migration Path: Rust → Grit

| Week | Action | Verification |
|------|--------|--------------|
| 1 | Add `#![deny(...)]` lints to lib.rs | CI passes |
| 2 | Fix all elided lifetime warnings | Zero warnings |
| 3 | Replace `.unwrap()` with `?` propagation | Clippy clean |
| 4 | Isolate unsafe code, add SAFETY comments | Audit complete |
| 5 | Eliminate wildcard match arms | All matches exhaustive |
| 6 | Update AI prompts with Grit rules | Review AI output quality |

---

## Appendix C: Terse — A Strict TypeScript for AI-Assisted Development

*Terse: concise, no wasted words—TypeScript stripped of ambiguity, saying exactly what it means.*

TypeScript scores 76/100, losing points on explicitness (★★★☆☆) and error handling (★★★☆☆). **Terse** closes these gaps through strict configuration and banned patterns.

### C.1 What Terse Provides

| TypeScript Weakness | Terse Rule | AI Benefit |
|---------------------|------------|------------|
| `any` type escape hatch | Banned entirely | AI always knows types |
| `as` type assertions | Banned (use type guards) | AI can't cast incorrectly |
| Non-null assertions `!` | Banned | AI handles null properly |
| Implicit `any` | `noImplicitAny: true` | AI must provide types |
| Unchecked index access | `noUncheckedIndexedAccess: true` | AI handles undefined |
| Narrowing lost after await | Capture in const before await | AI maintains type safety |
| Optional property confusion | `exactOptionalPropertyTypes: true` | `undefined` vs missing clear |
| Enums runtime behavior | Banned (use union types) | AI generates predictable code |

### C.2 Terse Rules Reference

#### Rule 1: No Type Escape Hatches
```typescript
// ❌ BANNED in Terse
function process(data: any): any { ... }
const result = value as SpecificType;
const name = user!.name;
// @ts-ignore
const x = brokenCode();

// ✅ Terse: Type guards and proper typing
function process<T extends Processable>(data: T): ProcessResult<T> { ... }

function isUser(value: unknown): value is User {
    return typeof value === 'object' && value !== null && 'id' in value;
}
if (isUser(value)) {
    const name = value.name;  // Properly narrowed
}

// ✅ Terse: Explicit null check instead of !
if (user != null) {
    const name = user.name;
}
```

#### Rule 2: Explicit Return Types
```typescript
// ❌ BANNED in Terse (public functions)
function getUser(id: string) {
    return db.find(id);  // AI guesses return type
}

// ✅ Terse: Explicit return type
function getUser(id: string): Promise<User | null> {
    return db.find(id);
}

// ✅ Terse: Arrow functions in callbacks may infer
const users = ids.map(id => getUser(id));  // OK, type flows from getUser
```

#### Rule 3: Safe Index Access
```typescript
// ❌ BANNED in Terse (without noUncheckedIndexedAccess)
const first = items[0];  // Type is T, but might be undefined!
const value = record[key];  // Type is V, but might be undefined!

// ✅ Terse: With noUncheckedIndexedAccess enabled
const first = items[0];  // Type is T | undefined
if (first != null) {
    process(first);  // Now safely T
}

// ✅ Terse: Explicit handling
const first = items.at(0);  // Returns T | undefined (clear intent)
```

#### Rule 4: Narrowing Preservation
```typescript
// ❌ PROBLEMATIC in Terse (AI often misses this)
async function process(user: User | null) {
    if (user == null) return;
    await someOperation();
    console.log(user.name);  // TypeScript says OK, but user could be reassigned!
}

// ✅ Terse: Capture narrowed value
async function process(user: User | null) {
    if (user == null) return;
    const validUser = user;  // NARROWED: captured before async boundary
    await someOperation();
    console.log(validUser.name);  // Guaranteed safe
}
```

#### Rule 5: Union Types Over Enums
```typescript
// ❌ BANNED in Terse
enum Status {
    Active = 'ACTIVE',
    Pending = 'PENDING',
}
// Enums have runtime behavior, can be iterated, have reverse mappings...

// ✅ Terse: Union types (zero runtime, full type safety)
type Status = 'active' | 'pending' | 'cancelled';

const STATUS = {
    Active: 'active',
    Pending: 'pending',
    Cancelled: 'cancelled',
} as const;
type Status = typeof STATUS[keyof typeof STATUS];
```

#### Rule 6: Explicit Object Construction
```typescript
// ❌ PROBLEMATIC in Terse (spread order confusion)
const config = { ...defaults, ...overrides };  // Which wins?

// ✅ Terse: Document or use explicit assignment
const config = {
    ...defaults,    // PRIORITY 1: base values
    ...overrides,   // PRIORITY 2: overrides win
};

// ✅ Terse: Or use Object.assign with explicit order
const config = Object.assign({}, defaults, overrides);
```

#### Rule 7: Result Type Pattern
```typescript
// Terse standard library addition
type Result<T, E = Error> = 
    | { ok: true; value: T }
    | { ok: false; error: E };

function Ok<T>(value: T): Result<T, never> {
    return { ok: true, value };
}

function Err<E>(error: E): Result<never, E> {
    return { ok: false, error };
}

// ✅ Terse: Functions return Result instead of throwing
async function fetchUser(id: string): Promise<Result<User, FetchError>> {
    try {
        const user = await db.find(id);
        if (!user) return Err({ code: 'NOT_FOUND', id });
        return Ok(user);
    } catch (e) {
        return Err({ code: 'DB_ERROR', cause: e });
    }
}

// Usage - AI can't forget error handling
const result = await fetchUser(id);
if (!result.ok) {
    console.error(result.error);
    return;
}
console.log(result.value.name);  // Safely User
```

### C.3 Enforcing Terse Today

```json
// tsconfig.json - Terse configuration
{
    "compilerOptions": {
        // Strict base
        "strict": true,
        
        // Terse additions
        "noUncheckedIndexedAccess": true,
        "exactOptionalPropertyTypes": true,
        "noPropertyAccessFromIndexSignature": true,
        
        // Prevent escape hatches
        "noImplicitAny": true,
        "noImplicitReturns": true,
        "noImplicitOverride": true,
        
        // Extra safety
        "noFallthroughCasesInSwitch": true,
        "forceConsistentCasingInFileNames": true,
        "verbatimModuleSyntax": true
    }
}
```

```javascript
// eslint.config.js - Terse ESLint rules
export default {
    rules: {
        // Rule 1: No escape hatches
        '@typescript-eslint/no-explicit-any': 'error',
        '@typescript-eslint/no-non-null-assertion': 'error',
        '@typescript-eslint/consistent-type-assertions': ['error', {
            assertionStyle: 'never'  // Ban `as` casts
        }],
        
        // Rule 2: Explicit return types
        '@typescript-eslint/explicit-function-return-type': ['error', {
            allowExpressions: true,  // Allow in callbacks
        }],
        
        // Rule 5: No enums
        'no-restricted-syntax': ['error', {
            selector: 'TSEnumDeclaration',
            message: 'Use union types instead of enums'
        }],
        
        // General safety
        '@typescript-eslint/no-floating-promises': 'error',
        '@typescript-eslint/no-misused-promises': 'error',
        '@typescript-eslint/await-thenable': 'error',
    }
};
```

### C.4 Terse AI Prompt Template

```
When writing TypeScript, follow Terse (strict TypeScript) rules:
1. NEVER use `any` - use `unknown` with type guards or generics
2. NEVER use `as` type assertions - use type guards to narrow
3. NEVER use non-null assertions `!` - use explicit null checks
4. ALWAYS add explicit return types to functions
5. ALWAYS handle index access as potentially undefined (use optional chaining)
6. ALWAYS capture narrowed values to a const before any await
7. USE union types instead of enums: type Status = 'active' | 'pending'
8. USE Result<T, E> pattern instead of throwing exceptions
9. COMMENT object spread order: // base < overrides
```

### C.5 Terse Scorecard (Projected)

Applying the proposed rubric to Terse yields the following projected improvements:

| Dimension | TypeScript | Terse | Improvement |
|-----------|------------|-------|-------------|
| Typing | ★★★★☆ | ★★★★★ | No escape hatches |
| Explicit | ★★★☆☆ | ★★★★★ | Explicit returns, guards |
| Simplicity | ★★★★☆ | ★★★★☆ | Same |
| Error Handling | ★★★☆☆ | ★★★★☆ | Result pattern |
| Ecosystem | ★★★★★ | ★★★★★ | Same |
| **Total** | **19 → 76** | **23 → 92** | Projected gain |

### C.6 Migration Path: TypeScript → Terse

| Week | Action | Verification |
|------|--------|--------------|
| 1 | Update tsconfig.json with Terse settings | CI passes |
| 2 | Add ESLint rules, fix `any` violations | Zero `any` usage |
| 3 | Replace `as` casts with type guards | Zero assertions |
| 4 | Add explicit return types to all functions | ESLint clean |
| 5 | Replace enums with union types | Zero enums |
| 6 | Introduce Result<T, E> for error handling | Key functions migrated |
| 7 | Update AI prompts with Terse rules | Review AI output quality |

**Expected outcome:** Elimination of type-escape and narrowing-related failure modes documented in Sections 6-7.

---

## Note on Kotlin

Kotlin does not have a "strict subset" appendix because it is already designed with AI-friendly principles: null safety is built into the type system, data classes encourage immutability, and sealed classes enable exhaustive matching. The main pitfall—Java interop platform types—is addressed through explicit nullability annotations and the patterns shown in [§6.4 Kotlin Generation Failures](#64-kotlin-generation-failures) and [§7.4 Kotlin Comprehension Failures](#74-kotlin-comprehension-failures). For teams using Kotlin, focus on: (1) avoiding `GlobalScope`, (2) treating all Java interop as nullable, and (3) using sealed classes over enums for state modeling.
