# Grit AI System Prompt

Add this to your AI assistant's system prompt when working with Rust code.

---

## System Prompt Addition

```
When writing Rust, follow Grit (strict Rust) rules:

1. ADD explicit lifetimes to all public function signatures
2. USE explicit conversions (.as_str(), .as_bytes(), .to_owned()) instead of relying on Deref
3. NEVER use .unwrap() or .expect() in library code - propagate errors with ?
4. NEVER use Box<dyn Any> - use generics or concrete types
5. ISOLATE unsafe code in dedicated modules with SAFETY comments
6. USE owned types (String, Vec<T>) in async function signatures, not references
7. MATCH all enum variants explicitly - never use _ catch-all without documenting why
8. USE thiserror for library error types, anyhow for applications
9. PREFER iterator chains (.iter().map().collect()) over imperative loops for transformations
10. STANDARDIZE on tokio for async runtime - never mix runtimes
```

---

## Extended Version (for complex projects)

```
When writing Rust, follow Grit (strict Rust) rules:

LIFETIMES:
- ADD explicit lifetimes to all public function signatures
- DOCUMENT which input lifetime the output borrows from
- PREFER 'a, 'b naming; use descriptive names ('input, 'output) for complex cases

CONVERSIONS:
- USE explicit conversions: .as_str(), .as_bytes(), .to_owned(), .clone()
- NEVER rely on implicit Deref coercion
- ANNOTATE type conversions: let x: TargetType = source.into();
- PREFER From/Into traits over `as` casts

ERROR HANDLING:
- NEVER use .unwrap() or .expect() in library code
- PROPAGATE errors with ? operator
- USE .ok_or() or .ok_or_else() to convert Option to Result
- APPLICATION entry points (main, tests) MAY use .expect() with descriptive messages
- USE thiserror for library error types (consistent #[error] formatting)
- USE anyhow for application error handling (quick prototyping)

TYPE SAFETY:
- NEVER use Box<dyn Any> - use generics or concrete types
- TRAIT objects are OK when genuinely needed - document with // TRAIT_OBJECT: reason
- PREFER monomorphization (generics) over dynamic dispatch

UNSAFE CODE:
- ISOLATE unsafe code in dedicated modules
- ADD /// SAFETY: comments explaining invariants
- MARK safe wrappers with clear precondition documentation

ASYNC:
- USE owned types (String, Vec<T>) in async function signatures
- AVOID references in async signatures - they cause lifetime complexity
- USE async move blocks when capturing variables
- STANDARDIZE on tokio - never mix async runtimes (async-std, smol, etc.)
- USE tokio utilities (tokio::fs, tokio::time, tokio::sync) consistently

PATTERN MATCHING:
- MATCH all enum variants explicitly
- NEVER use _ catch-all without documenting why
- USE pattern | pattern for variants with identical handling

ITERATION:
- PREFER iterator chains (.iter().filter().map().collect()) for transformations
- AVOID imperative for loops with mutable accumulators
- USE direct iteration (for item in &items) over index-based (for i in 0..items.len())
- ITERATOR methods are OK: .enumerate(), .zip(), .flatten(), .flat_map()

DOCUMENTATION:
- ADD doc comments to all public items
- DOCUMENT # Errors section for fallible functions
- DOCUMENT # Panics section if any panic is possible
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
