# Terse — Strict TypeScript for AI-Assisted Development

*Terse: concise, no wasted words—TypeScript stripped of ambiguity, saying exactly what it means.*

TypeScript scores 76/100 for AI-assisted development, losing points on explicitness (3/5) and error handling (3/5). **Terse** closes these gaps through strict configuration and banned patterns.

> **Empirical basis:** Terse has the **strongest empirical support** of the three strict subsets. Mündler et al. [PLDI 2025] demonstrated that type-constrained decoding in TypeScript reduced compilation errors by **74.8%** on HumanEval and **56.0%** on MBPP. Their finding that 94% of compilation errors result from failing type checks directly validates Terse's core rules (banning `any`, type assertions, and non-null assertions).

## Quick Start

```bash
# Copy the config files to your project
cp tsconfig.json eslint.config.js your-project/

# Install required ESLint dependencies
npm install -D eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser

# Run the linter
npx eslint . --ext .ts,.tsx
```

## What Terse Fixes

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

**Bug Pattern Prevention** (based on Tambon et al., 2025):

| Terse Rule | Prevents Bug Pattern |
|------------|---------------------|
| No `any` | "Wrong Input Type," "Hallucinated Object" |
| No type assertions | "Wrong Input Type," "Misinterpretations" |
| No non-null assertions | "Missing Corner Case" |
| Safe index access | "Missing Corner Case," "Wrong Attribute" |
| Narrowing preservation | "Misinterpretations" |
| Result pattern | "Missing Corner Case" |

## The Rules

### Rule 1: No Type Escape Hatches
```typescript
// BANNED in Terse
function process(data: any): any { ... }
const result = value as SpecificType;
const name = user!.name;

// Terse: Type guards and proper typing
function isUser(value: unknown): value is User {
    return typeof value === 'object' && value !== null && 'id' in value;
}
```

### Rule 2: Explicit Return Types
```typescript
// BANNED in Terse (public functions)
function getUser(id: string) {
    return db.find(id);
}

// Terse: Explicit return type
function getUser(id: string): Promise<User | null> {
    return db.find(id);
}
```

### Rule 3: Safe Index Access
```typescript
// With noUncheckedIndexedAccess
const first = items[0];  // Type is T | undefined
if (first != null) {
    process(first);      // Now safely T
}
```

### Rule 4: Narrowing Preservation
```typescript
// PROBLEMATIC (narrowing lost after await)
async function process(user: User | null) {
    if (user == null) return;
    await someOperation();
    console.log(user.name);  // Unsafe!
}

// Terse: Capture narrowed value
async function process(user: User | null) {
    if (user == null) return;
    const validUser = user;  // NARROWED
    await someOperation();
    console.log(validUser.name);  // Safe
}
```

### Rule 5: Union Types Over Enums
```typescript
// BANNED in Terse
enum Status { Active = 'ACTIVE', Pending = 'PENDING' }

// Terse: Union types
type Status = 'active' | 'pending' | 'cancelled';
```

### Rule 6: Result Type Pattern
```typescript
type Result<T, E = Error> =
    | { ok: true; value: T }
    | { ok: false; error: E };

// Functions return Result instead of throwing
async function fetchUser(id: string): Promise<Result<User, FetchError>> {
    // ...
}
```

## Scorecard

| Dimension | TypeScript | Terse | Improvement |
|-----------|------------|-------|-------------|
| Typing | 4/5 | 5/5 | No escape hatches *(empirically validated)* |
| Explicit | 3/5 | 5/5 | Explicit returns, guards |
| Simplicity | 4/5 | 4/5 | Same |
| Error Handling | 3/5 | 4/5 | Result pattern |
| Ecosystem | 5/5 | 5/5 | Same |
| **Total** | **76/100** | **92/100** | **+16 points** *(type rules validated)* |

*Unlike Cog and Grit, Terse's core type-constraint rules have **direct empirical support**: Mündler et al. demonstrated 74.8%/56.0% error reduction with TypeScript type constraints. The additional rules (Result pattern, narrowing preservation) extend beyond the study but follow the same design principles. See the [full paper](../Amphigraphic_Language_Guide.md) for methodology and research references.*

## Files in This Directory

- `tsconfig.json` — Ready-to-copy TypeScript configuration
- `eslint.config.js` — Ready-to-copy ESLint configuration
- `prompt.md` — AI system prompt template
- `examples/before.ts` — Common AI mistakes in TypeScript
- `examples/after.ts` — Terse-compliant versions

## Learn More

See the full [Amphigraphic Language Guide](../Amphigraphic_Language_Guide.md) for the complete rationale and additional patterns.
