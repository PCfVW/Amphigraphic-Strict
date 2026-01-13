# AI Failure Modes: Expanded Examples

This document catalogs common AI coding mistakes by category, with examples and prevention strategies.

## 1. Type Ambiguity Failures

AI models predict "most likely" code. Without type constraints, multiple interpretations are equally valid statistically.

### Python: Untyped Parameters

```python
# AI-generated code
def process(data):
    return data.get('key')  # Assumes dict, but what if it's a list?

# What AI should generate
def process(data: dict[str, Any]) -> Any:
    return data.get('key')
```

**Prevention:** Add type hints to all parameters. Run `mypy --strict`.

### JavaScript: Type Coercion

```javascript
// AI-generated code
function addOne(value) {
  return value + 1;  // If value is "5", returns "51"!
}

// What AI should generate (TypeScript)
function addOne(value: number): number {
  return value + 1;
}
```

**Prevention:** Migrate to TypeScript with strict mode.

### Go: Interface{} Confusion

```go
// AI-generated code
func process(data interface{}) interface{} {
    // AI can't know what operations are valid
    return data
}

// What AI should generate (Cog)
func process[T Processor](data T) Result[T] {
    return Ok(data.Process())
}
```

**Prevention:** Ban `interface{}`/`any`. Use generics.

---

## 2. Implicit Behavior Failures

AI learns surface patterns. Implicit runtime behavior isn't visible in code text.

### Python: Mutable Default Arguments

```python
# AI-generated code
def append_to(item, target=[]):  # BUG: shared list!
    target.append(item)
    return target

# Correct version
def append_to(item, target=None):
    if target is None:
        target = []
    target.append(item)
    return target
```

**Prevention:** Add linter rule forbidding mutable defaults.

### JavaScript: `this` Binding

```javascript
// AI-generated code
const handler = obj.method;
button.onClick(handler);  // BUG: `this` is undefined

// Correct version
button.onClick(() => obj.method());
// or
button.onClick(obj.method.bind(obj));
```

**Prevention:** Add prompt rule: "Always use arrow functions or explicit bind for callbacks."

### Rust: Implicit Deref

```rust
// AI-generated code
fn process(s: &str) { ... }
let string = String::from("hello");
process(&string);  // Implicit Deref - what type is passed?

// What AI should generate (Grit)
process(string.as_str());  // Explicit conversion
```

**Prevention:** Require explicit `.as_str()`, `.to_owned()` conversions.

---

## 3. Concurrency Failures

AI frequently generates race conditions and incorrect concurrent patterns.

### Go: Loop Variable Capture

```go
// AI-generated code
for _, item := range items {
    go func() {
        process(item)  // BUG: All goroutines process last item
    }()
}

// Correct version (Cog)
for _, item := range items {
    go func(it Item) {
        process(it)
    }(item)
}
```

**Prevention:** Linter rule for `loopclosure`. Prompt rule for goroutine arguments.

### Kotlin: GlobalScope Leaks

```kotlin
// AI-generated code
GlobalScope.launch {
    fetchData()  // BUG: Outlives calling scope, can leak
}

// Correct version
viewModelScope.launch {  // or coroutineScope { }
    fetchData()
}
```

**Prevention:** Ban `GlobalScope`. Require structured concurrency.

### Rust: Async Lifetime Errors

```rust
// AI-generated code
async fn fetch(&self, id: &str) -> User {
    // Complex lifetime requirements
}

// What AI should generate (Grit)
async fn fetch(db: Db, id: String) -> Result<User, Error> {
    // Owned types, no lifetime complexity
}
```

**Prevention:** Owned types in async signatures.

---

## 4. Error Handling Failures

AI frequently forgets or mishandles error paths.

### Go: Ignored Errors

```go
// AI-generated code
result, _ := mightFail()  // Error silently discarded

// Correct version (Cog)
result, err := mightFail()
if err != nil {
    return fmt.Errorf("operation failed: %w", err)
}
```

**Prevention:** `errcheck` linter. Prompt rule for explicit handling.

### Rust: Unwrap in Library Code

```rust
// AI-generated code
let user = users.get(&id).unwrap();  // Panics!

// Correct version (Grit)
let user = users.get(&id).ok_or(Error::NotFound)?;
```

**Prevention:** Deny `clippy::unwrap_used` in libraries.

### TypeScript: Missing Null Checks

```typescript
// AI-generated code
function getFirst(items: string[]): string {
  return items[0].toUpperCase();  // BUG: Crashes on empty
}

// Correct version (Terse)
function getFirst(items: readonly string[]): string | undefined {
  const first = items[0];  // Type is string | undefined
  return first?.toUpperCase();
}
```

**Prevention:** `noUncheckedIndexedAccess` in tsconfig.

---

## 5. Nil/Null Confusion Failures

AI often misunderstands nil/null semantics.

### Go: Typed Nil Interface

```go
// AI-generated code
func getError() error {
    var err *MyError = nil
    return err  // BUG: Interface is non-nil!
}

// Correct version (Cog)
func getError() error {
    if noError {
        return nil  // Always bare nil
    }
    return &MyError{msg: "failed"}
}
```

**Prevention:** Prompt rule: "Return bare `nil` for interface types."

### TypeScript: Narrowing After Await

```typescript
// AI-generated code
async function process(user: User | null) {
  if (!user) return;
  await save(user);
  console.log(user.name);  // Technically unsafe pattern
}

// Correct version (Terse)
async function process(user: User | null) {
  if (!user) return;
  const validUser = user;  // Capture before await
  await save(validUser);
  console.log(validUser.name);
}
```

**Prevention:** Prompt rule: "Capture narrowed values before await."

---

## 6. Pattern Matching Failures

AI often uses catch-all patterns that hide bugs.

### Rust: Wildcard Match Arms

```rust
// AI-generated code
match status {
    Status::Active => handle_active(),
    _ => {}  // What's being ignored?
}

// Correct version (Grit)
match status {
    Status::Active => handle_active(),
    Status::Pending => {}      // EXPLICIT
    Status::Cancelled => {}    // EXPLICIT
}
```

**Prevention:** Deny `clippy::wildcard_enum_match_arm`.

### TypeScript: Non-Exhaustive Switches

```typescript
// AI-generated code
switch (status) {
  case 'active':
    return handleActive();
  default:
    return null;  // Silently handles new cases
}

// Correct version (Terse)
switch (status) {
  case 'active':
    return handleActive();
  case 'pending':
    return handlePending();
  case 'cancelled':
    return handleCancelled();
}
// TypeScript ensures exhaustiveness with union types
```

**Prevention:** Union types + `switch-exhaustiveness-check` ESLint rule.

---

## 7. Resource Management Failures

AI often misses cleanup requirements.

### Go: Unclosed Resources

```go
// AI-generated code
resp, err := http.Get(url)
if err != nil { return err }
data, _ := io.ReadAll(resp.Body)  // BUG: Body never closed

// Correct version
resp, err := http.Get(url)
if err != nil { return err }
defer resp.Body.Close()
data, err := io.ReadAll(resp.Body)
```

**Prevention:** `bodyclose` linter.

### Rust: Drop Order Dependencies

```rust
// AI-generated code (order matters but not documented)
struct Connection {
    writer: BufWriter<TcpStream>,
    stream: TcpStream,
}

// Correct version (Grit)
/// Fields drop in declaration order:
/// 1. writer - flushes buffer
/// 2. stream - closes connection
struct Connection {
    writer: BufWriter<TcpStream>,  // DROP FIRST
    stream: TcpStream,              // DROP SECOND
}
```

**Prevention:** Document drop order in struct comments.

---

## Summary: Prevention by Language

| Language | Top 3 Failure Modes | Prevention Tools |
|----------|---------------------|------------------|
| **Go** | Error ignore, typed nil, goroutine capture | golangci-lint, Cog rules |
| **Rust** | Lifetime elision, unwrap, wildcard match | Clippy pedantic, Grit rules |
| **TypeScript** | any/as, unchecked index, narrowing loss | strict tsconfig, Terse rules |
| **Kotlin** | Platform types, GlobalScope, scope functions | detekt, explicit annotations |
| **Python** | Missing types, mutable defaults, exceptions | mypy --strict, type hints |

The strict subsets (Cog, Grit, Terse) are specifically designed to prevent these failure modes through enforceable linter rules and AI prompt additions.
