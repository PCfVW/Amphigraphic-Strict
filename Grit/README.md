# Grit — Strict Rust for AI-Assisted Development

*Grit: unyielding toughness and determination—Rust's rigor, with no shortcuts allowed.*

Rust scores 84/100 for AI-assisted development, with its main weakness being complexity (★★★☆☆). **Grit** is a restricted subset that makes implicit behaviors explicit, eliminating the patterns where AI stumbles.

> **Empirical basis:** Grit's rules are *inferred* from general LLM error research rather than Rust-specific studies. The type erasure ban is supported by research showing 33.6% of LLM failures are type errors [TyFlow, 2025]. The explicit lifetime rules target the complexity issues identified in Dou et al. [2024]. No direct study has yet measured AI accuracy improvements for Rust-specific constraints—this represents an open research opportunity.

## Quick Start

```bash
# Add the lints section to your Cargo.toml
cat Cargo.toml >> your-project/Cargo.toml

# Or copy the lib.rs deny directives
cp lib.rs your-project/src/

# Run clippy with pedantic checks
cargo clippy -- -D warnings -D clippy::pedantic
```

## What Grit Fixes

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
| Ad-hoc error types | Use thiserror for libraries | AI generates consistent errors |
| Multiple iteration styles | Prefer iterator chains | AI uses idiomatic patterns |
| Mixed async runtimes | Standardize on tokio | AI uses consistent async code |

**Bug Pattern Prevention** (based on Tambon et al., 2025):

| Grit Rule | Prevents Bug Pattern |
|-----------|---------------------|
| No type erasure | "Wrong Input Type," "Hallucinated Object" |
| No unwrap/expect | "Missing Corner Case" |
| Explicit lifetimes | "Misinterpretations," "Wrong Attribute" |
| Exhaustive matching | "Missing Corner Case" |
| Explicit conversions | "Wrong Input Type" |

## The Rules

### Rule 1: Explicit Lifetimes
```rust
// BANNED in Grit (public APIs)
pub fn get_name(&self) -> &str { ... }

// Grit: Lifetimes explicit
pub fn get_name<'a>(&'a self) -> &'a str { ... }
```

### Rule 2: Explicit Conversions
```rust
// BANNED in Grit
process(&string);  // Implicit Deref coercion

// Grit: Explicit conversion
process(string.as_str());
```

### Rule 3: No Panic in Libraries
```rust
// BANNED in Grit (library code)
let value = map.get(&key).unwrap();

// Grit: Propagate errors
let value = map.get(&key).ok_or(Error::NotFound)?;
```

### Rule 4: No Type Erasure
```rust
// BANNED in Grit
fn store(item: Box<dyn Any>) { ... }

// Grit: Use generics
fn store<T: Item>(item: T) { ... }
```

### Rule 5: Unsafe Isolation
```rust
// BANNED in Grit (mixed with safe code)
fn process(data: &[u8]) -> Value {
    unsafe { ptr::read(...) }
}

// Grit: Isolate in dedicated module with SAFETY comments
// src/unsafe_ops.rs
#![allow(unsafe_code)]
/// SAFETY: Caller must ensure data is valid Value layout
pub unsafe fn transmute_value(data: &[u8]) -> Value { ... }
```

### Rule 6: Owned Async Signatures
```rust
// BANNED in Grit
async fn fetch_user(&self, id: &str) -> User { ... }

// Grit: Async takes owned types
async fn fetch_user(db: Db, id: String) -> Result<User, Error> { ... }
```

### Rule 7: Exhaustive Matching
```rust
// BANNED in Grit
match status {
    Status::Active => handle_active(),
    _ => {}  // What's ignored?
}

// Grit: All variants explicit
match status {
    Status::Active => handle_active(),
    Status::Pending => {}   // EXPLICIT: no action needed
    Status::Cancelled => {} // EXPLICIT: no action needed
    Status::Expired => {}   // EXPLICIT: no action needed
}
```

### Rule 8: Standard Error Pattern
```rust
// BANNED in Grit (ad-hoc error types)
#[derive(Debug)]
enum MyError { Io(std::io::Error), Parse(ParseIntError) }
impl std::fmt::Display for MyError { ... }  // Boilerplate

// Grit: Use thiserror for libraries
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ServiceError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("not found: {id}")]
    NotFound { id: String },
}
```

### Rule 9: Prefer Iterators Over Loops
```rust
// BANNED in Grit (imperative loops for transformations)
let mut results = Vec::new();
for item in items {
    if item.is_valid() {
        results.push(item.transform());
    }
}

// Grit: Iterator chains
let results: Vec<_> = items.iter()
    .filter(|item| item.is_valid())
    .map(|item| item.transform())
    .collect();
```

### Rule 10: Single Async Runtime
```rust
// BANNED in Grit (mixing runtimes)
use async_std::task;
use tokio::fs;  // Different runtime!

// Grit: Standardize on tokio
use tokio::{fs, io, net, sync, time};

#[tokio::main]
async fn main() -> Result<(), Error> {
    let contents = fs::read_to_string("file.txt").await?;
    Ok(())
}
```

## Scorecard

| Dimension | Rust | Grit | Improvement |
|-----------|------|------|-------------|
| Typing | 5/5 | 5/5 | Same (already excellent) |
| Explicit | 5/5 | 5/5 | Same (rules reinforce) |
| Simplicity | 3/5 | 4/5 | "One way" rules reduce variation |
| Error Handling | 5/5 | 5/5 | Same (already excellent) |
| Ecosystem | 3/5 | 3/5 | Same |
| **Total** | **84/100** | **92/100** | **+8 points** *(theoretical, unvalidated)* |

*Scores are theoretical projections based on documented failure modes and general LLM research. They have **not been empirically validated** for Rust specifically. See the [full paper](../Amphigraphic_Language_Guide.md) for methodology and research references.*

## Files in This Directory

- `Cargo.toml` — Ready-to-copy `[lints]` section
- `lib.rs` — `#![deny(...)]` template for crate root
- `prompt.md` — AI system prompt template
- `examples/before.rs` — Common AI mistakes in Rust
- `examples/after.rs` — Grit-compliant versions

## Learn More

See the full [Amphigraphic Language Guide](../Amphigraphic_Language_Guide.md) for the complete rationale and additional patterns.
