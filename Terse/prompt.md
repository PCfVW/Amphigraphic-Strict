# Terse AI System Prompt

Add this to your AI assistant's system prompt when working with TypeScript code.

---

## System Prompt Addition

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

---

## Extended Version (for complex projects)

```
When writing TypeScript, follow Terse (strict TypeScript) rules:

TYPE SAFETY:
- NEVER use `any` - use `unknown` with type guards or generics
- NEVER use `as` type assertions - use type guards to narrow
- NEVER use non-null assertions (!) - use explicit null checks
- NEVER use @ts-ignore - fix the underlying type issue

FUNCTION SIGNATURES:
- ALWAYS add explicit return types to all functions
- ALWAYS add explicit parameter types (never infer)
- USE readonly for parameters that shouldn't be mutated
- PREFER function declarations over arrow functions for top-level

NULL HANDLING:
- ALWAYS handle index access as potentially undefined
- USE optional chaining (?.) for property access chains
- USE nullish coalescing (??) instead of || for defaults
- CAPTURE narrowed values to const before any await

TYPE DEFINITIONS:
- USE union types instead of enums: type Status = 'active' | 'pending'
- USE branded types for type-safe IDs: type UserId = string & { readonly brand: unique symbol }
- USE readonly for immutable properties: readonly id: string
- PREFER interfaces for object shapes, types for unions

ERROR HANDLING:
- USE Result<T, E> pattern instead of throwing exceptions
- DEFINE specific error types: type FetchError = { code: 'NOT_FOUND' | 'NETWORK' }
- NEVER catch and ignore errors - handle or propagate
- TYPE catch blocks: catch (error: unknown)

OBJECT CONSTRUCTION:
- COMMENT object spread order: // base < overrides (last wins)
- USE satisfies for type-safe object literals
- PREFER explicit object construction over spreading

ASYNC CODE:
- ALWAYS handle Promise rejections (no floating promises)
- CAPTURE narrowed values before await boundaries
- USE Promise.all for parallel operations
- PREFER async/await over .then() chains

DOCUMENTATION:
- ADD JSDoc @param and @returns for public functions
- ADD @throws documentation if using exceptions
- ADD @example for complex functions

COMMENTS:
- ADD `// NARROWED:` comments when capturing narrowed values before async boundaries
- ADD `// FALLBACK:` comments when providing default values with ?? or ||
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

---

## Result Type Implementation

Add this utility to your project:

```typescript
// result.ts - Terse Result type implementation

export type Result<T, E = Error> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: E };

export function Ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

export function Err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

export function isOk<T, E>(result: Result<T, E>): result is { ok: true; value: T } {
  return result.ok;
}

export function isErr<T, E>(result: Result<T, E>): result is { ok: false; error: E } {
  return !result.ok;
}

export function unwrap<T, E>(result: Result<T, E>): T {
  if (result.ok) {
    return result.value;
  }
  throw result.error;
}

export function unwrapOr<T, E>(result: Result<T, E>, defaultValue: T): T {
  if (result.ok) {
    return result.value;
  }
  return defaultValue;
}
```
