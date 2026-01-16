# Cog — Strict Go for AI-Assisted Development

*Cog: a precise mechanical tooth that meshes perfectly—like Go's simplicity, but with zero play.*

Go scores 84/100 for AI-assisted development, but its remaining weaknesses cause predictable AI failures. **Cog** is a restricted subset of Go that eliminates these failure modes through enforceable rules.

> **Empirical basis:** Cog's rules are *inferred* from general LLM error research rather than Go-specific studies. The type erasure ban is supported by research showing 33.6% of LLM failures are type errors [TyFlow, 2025]. No direct study has yet measured AI accuracy improvements for Go-specific constraints—this represents an open research opportunity.

## Quick Start

```bash
# Copy the linter config to your project
cp .golangci.yml your-project/

# Run the linter
golangci-lint run ./...
```

## What Cog Fixes

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

**Bug Pattern Prevention** (based on Tambon et al., 2025):

| Cog Rule | Prevents Bug Pattern |
|----------|---------------------|
| No type erasure | "Wrong Input Type," "Hallucinated Object" |
| Explicit error handling | "Missing Corner Case" |
| No named returns | "Misinterpretations" |
| Interface nil safety | "Wrong Attribute" |

## The Rules

### Rule 1: No Type Erasure
```go
// BANNED in Cog
func process(data any) any { ... }

// Cog: Use generics or concrete types
func process[T Processor](data T) Result[T] { ... }
```

### Rule 2: Explicit Error Handling
```go
// BANNED in Cog
result, _ := mightFail()

// Cog: Handle or explicitly mark as intentionally ignored
result, err := mightFail()
if err != nil {
    return fmt.Errorf("context: %w", err)
}
```

### Rule 3: No Named Returns
```go
// BANNED in Cog
func calculate() (result int, err error) {
    result = 42
    return  // Ambiguous
}

// Cog: Explicit returns only
func calculate() (int, error) {
    return 42, nil
}
```

### Rule 4: Interface Nil Safety
```go
// BANNED in Cog
func getError() error {
    var err *MyError = nil
    return err  // Non-nil interface with nil value!
}

// Cog: Return bare nil for interfaces
func getError() error {
    if noError {
        return nil
    }
    return &MyError{msg: "failed"}
}
```

### Rule 5: Safe Goroutine Capture

> **Note:** Go 1.22+ changed loop variable semantics so each iteration gets a fresh variable. This rule remains valuable for (1) codebases not yet on Go 1.22+, (2) AI models trained on pre-1.22 code, and (3) explicit clarity about capture intent.

```go
// BANNED in Cog (especially pre-Go 1.22)
for _, item := range items {
    go func() {
        process(item)  // Captures loop variable by reference (pre-1.22 bug)
    }()
}

// Cog: Pass as argument (works on all Go versions, explicit intent)
for _, item := range items {
    go func(it Item) {
        process(it)
    }(item)
}
```

### Rule 6: Explicit Slice Initialization
```go
// BANNED in Cog
var results []Item  // nil slice - JSON encodes to null

// Cog: Always use make for empty slices
results := make([]Item, 0)  // JSON encodes to []
```

## Scorecard

| Dimension | Go | Cog | Improvement |
|-----------|-----|-----|-------------|
| Typing | 4/5 | 5/5 | Generics-only, no type erasure |
| Explicit | 5/5 | 5/5 | Already excellent |
| Simplicity | 5/5 | 4/5 | Slight overhead from Result type |
| Error Handling | 3/5 | 5/5 | Enforced, wrapped, traceable |
| Ecosystem | 4/5 | 4/5 | Same (it's still Go) |
| **Total** | **84/100** | **96/100** | **+12 points** *(theoretical, unvalidated)* |

*Scores are theoretical projections based on documented failure modes and general LLM research. They have **not been empirically validated** for Go specifically. See the [full paper](../Amphigraphic_Language_Guide.md) for methodology and research references.*

## Files in This Directory

- `.golangci.yml` — Ready-to-copy linter configuration
- `prompt.md` — AI system prompt template
- `examples/before.go` — Common AI mistakes in Go
- `examples/after.go` — Cog-compliant versions

## Learn More

See the full [Amphigraphic Language Guide](../Amphigraphic_Language_Guide.md) for the complete rationale and additional patterns.
