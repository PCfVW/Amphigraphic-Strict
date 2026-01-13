# Scoring Rubric: The 5-Dimension Framework

This document explains the scoring framework used to evaluate languages for AI-assisted development.

## Overview

Each language is scored on 5 dimensions, with each dimension worth up to 5 stars (20 points each, 100 points total).

```
AI Accuracy = f(Type Strictness × Explicitness × Simplicity)
            ÷ (Implicit Behaviors × Metaprogramming × Syntax Variants)
```

## The Five Dimensions

### 1. Typing (★★★★★ = 20 points)

How well does the type system constrain valid code?

| Stars | Criteria |
|-------|----------|
| ★☆☆☆☆ | Dynamic typing, types optional (JavaScript) |
| ★★☆☆☆ | Optional type hints, not enforced (Python) |
| ★★★☆☆ | Static typing with escape hatches (TypeScript with `any`) |
| ★★★★☆ | Strong static typing, some gaps (Go with `interface{}`) |
| ★★★★★ | Full static typing, no escape hatches (Rust, Grit) |

**Why it matters for AI:** Strong types constrain the space of valid completions. When AI can generate `"5" + 1` that compiles, it will sometimes generate bugs.

### 2. Explicitness (★★★★★ = 20 points)

How visible is program behavior in the source code?

| Stars | Criteria |
|-------|----------|
| ★☆☆☆☆ | Heavy metaprogramming, runtime behavior unpredictable (Ruby) |
| ★★☆☆☆ | Significant implicit behavior (Python decorators, JS `this`) |
| ★★★☆☆ | Some implicit behavior (TypeScript type narrowing) |
| ★★★★☆ | Mostly explicit, minor implicit behaviors (Kotlin coroutines) |
| ★★★★★ | What you see is what runs (Go, Rust) |

**Why it matters for AI:** AI learns from code text. Implicit runtime behavior isn't visible and gets missed.

### 3. Simplicity (★★★★★ = 20 points)

How many ways can the same thing be expressed?

| Stars | Criteria |
|-------|----------|
| ★☆☆☆☆ | Many ways to do everything (C++, Perl) |
| ★★☆☆☆ | Multiple paradigms, many syntax options (Rust) |
| ★★★☆☆ | Some variation but conventions exist (TypeScript, Kotlin) |
| ★★★★☆ | Strong conventions, few alternatives (Python) |
| ★★★★★ | One obvious way to do things (Go) |

**Why it matters for AI:** Multiple valid solutions increase prediction entropy. AI picks "most likely" which may not match project conventions.

### 4. Error Handling (★★★★★ = 20 points)

How does the language handle failure cases?

| Stars | Criteria |
|-------|----------|
| ★☆☆☆☆ | Errors as exceptions, easily forgotten (JavaScript) |
| ★★☆☆☆ | Mix of exceptions and return values (Python, C++) |
| ★★★☆☆ | Multi-value returns but not enforced (Go) |
| ★★★★☆ | Result types common but not universal (Kotlin) |
| ★★★★★ | Result types mandatory, compiler-enforced (Rust) |

**Why it matters for AI:** AI frequently forgets error paths. Languages that enforce error handling produce safer AI code.

### 5. Ecosystem (★★★★★ = 20 points)

How well-supported is the language for real-world development?

| Stars | Criteria |
|-------|----------|
| ★☆☆☆☆ | Limited libraries, niche tooling (OCaml) |
| ★★☆☆☆ | Growing ecosystem, some gaps (Rust - improving) |
| ★★★☆☆ | Solid ecosystem for most use cases (Go, Kotlin) |
| ★★★★☆ | Large ecosystem, good tooling (Go, TypeScript) |
| ★★★★★ | Massive ecosystem, industry standard (JavaScript, Python, C++) |

**Why it matters for AI:** AI training data quality correlates with ecosystem size. More code = better patterns learned.

## Language Scorecards

### Standard Languages

| Language | Typing | Explicit | Simplicity | Error | Ecosystem | **Total** |
|----------|--------|----------|------------|-------|-----------|-----------|
| **Go** | ★★★★☆ | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★★☆ | **84/100** |
| **Kotlin** | ★★★★★ | ★★★★☆ | ★★★★☆ | ★★★★☆ | ★★★★☆ | **84/100** |
| **Rust** | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★★★ | ★★★☆☆ | **84/100** |
| **TypeScript** | ★★★★☆ | ★★★☆☆ | ★★★★☆ | ★★★☆☆ | ★★★★★ | **76/100** |
| **Python** | ★★☆☆☆ | ★★☆☆☆ | ★★★★☆ | ★★☆☆☆ | ★★★★★ | **60/100** |
| **JavaScript** | ★☆☆☆☆ | ★☆☆☆☆ | ★★★☆☆ | ★☆☆☆☆ | ★★★★★ | **44/100** |

### Strict Subsets

| Subset | Typing | Explicit | Simplicity | Error | Ecosystem | **Total** |
|--------|--------|----------|------------|-------|-----------|-----------|
| **Cog** (Go) | ★★★★★ | ★★★★★ | ★★★★☆ | ★★★★★ | ★★★★☆ | **96/100** |
| **Terse** (TS) | ★★★★★ | ★★★★★ | ★★★★☆ | ★★★★☆ | ★★★★★ | **92/100** |
| **Grit** (Rust) | ★★★★★ | ★★★★★ | ★★★★☆ | ★★★★★ | ★★★☆☆ | **92/100** |

*Note: Scores are proposed estimates based on documented failure modes, not empirically measured values. Final scores include qualitative adjustments for rule effectiveness, not just star arithmetic.*

## How to Use This Framework

### Evaluating a New Language

1. **Typing**: Can the compiler catch `"5" + 1`? Are there escape hatches like `any`?
2. **Explicitness**: Are there default mutable values? Can methods appear at runtime?
3. **Simplicity**: How many ways can you iterate a list? How many ways to define a function?
4. **Error Handling**: Is error handling enforced or optional?
5. **Ecosystem**: Is there a large corpus of high-quality code for AI to learn from?

### Improving Your Current Stack

For each dimension where your language scores below 4 stars:
1. Identify the specific weaknesses
2. Apply linter rules or conventions to address them
3. Add AI prompt rules to prevent the weakness

**Example:** Python scores ★★☆☆☆ on Typing
- **Fix:** Add type hints everywhere, run `mypy --strict`
- **Result:** Effective score improves to ★★★★☆

### Choosing for a New Project

```
Need JS ecosystem?          → TypeScript (76) + Terse rules (92)
Need JVM ecosystem?         → Kotlin (84)
Need maximum correctness?   → Rust (84) + Grit rules (92)
Need maximum simplicity?    → Go (84) + Cog rules (96)
```

## Interpreting Scores

| Score | AI Experience |
|-------|---------------|
| 90+ | AI code is production-ready with minimal review |
| 80-89 | AI code needs targeted review for known issues |
| 70-79 | AI code needs careful review, expect 20-30% bugs |
| 60-69 | AI code needs extensive review and testing |
| Below 60 | AI code is a starting point, not a solution |

The strict subsets (Cog, Grit, Terse) are designed to push scores into the 90+ range through enforceable constraints.
