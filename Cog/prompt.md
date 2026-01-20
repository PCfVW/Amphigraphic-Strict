# Cog AI System Prompt

Add this to your AI assistant's system prompt when working with Go code.

---

## System Prompt Addition

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

---

## Extended Version (for complex projects)

```
When writing Go, follow Cog (strict Go) rules:

TYPE SAFETY:
- NEVER use `any` or `interface{}` - always use generics or concrete types
- ALWAYS annotate function parameters and return types explicitly
- USE type assertions only with comma-ok pattern: v, ok := x.(Type)

ERROR HANDLING:
- ALWAYS handle errors explicitly - never use `_` to ignore without comment
- ALWAYS wrap errors with context: fmt.Errorf("operation failed: %w", err)
- NEVER return typed nil for interface types - always return bare `nil`
- CHECK errors immediately after the call that produces them

FUNCTION DESIGN:
- NEVER use named returns - always return explicit values
- NEVER use bare `return` statements - always `return value, err`
- PREFER small functions with single responsibility
- USE Result[T] pattern for operations that can fail

CONCURRENCY:
- ALWAYS pass loop variables as goroutine arguments
- USE context.Context for cancellation and timeouts
- PREFER channels over shared memory with mutexes

DATA STRUCTURES:
- ALWAYS use `make([]T, 0)` for empty slices that will be JSON-encoded
- USE explicit struct initialization: Type{field: value}
- PREFER immutable data - return new values instead of modifying

COMMENTS:
- ADD `// CAPTURE:` comments when copying loop variables for goroutines
- ADD `// IGNORE:` comments when intentionally discarding errors
- ADD `// FALLBACK:` comments when providing default values on error
- ADD `// SAFETY:` comments explaining nil return decisions
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
