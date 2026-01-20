# Gizmo — Strict Zig for AI-Assisted Development

*Gizmo: a precise, clever device—Zig's explicit machinery, with every gear visible.*

Zig scores an estimated 72/100 for AI-assisted development. Its explicit design philosophy (no hidden control flow, no hidden allocations) is already AI-friendly, but AI tools still struggle with allocator ownership, error handling verbosity, and `comptime` complexity. **Gizmo** is a restricted subset that makes these patterns unambiguous.

> **Empirical basis:** Gizmo's rules are *inferred* from general LLM error research and Zig's documented design rationale rather than Zig-specific AI studies. The allocator ownership rules target the "Wrong Attribute" and "Missing Corner Case" failures identified by Tambon et al. [2025]. The error handling rules extend research showing 33.6% of LLM failures are type errors [TyFlow, 2025] to Zig's error union types. No direct study has yet measured AI accuracy improvements for Zig-specific constraints—this represents an open research opportunity.

## Quick Start

```bash
# Copy the build.zig settings to your project
# (Gizmo uses standard Zig with strict conventions)

# Run tests with all safety checks
zig build test

# Build with release-safe for production (keeps safety checks)
zig build -Doptimize=ReleaseSafe
```

## What Gizmo Fixes

| Zig Weakness | Gizmo Rule | AI Benefit |
|--------------|------------|------------|
| Allocator ownership unclear | Document allocator ownership in comments | AI knows who frees memory |
| Implicit error discarding | All `try` in explicit error-handling blocks | AI sees error paths |
| `comptime` over-complexity | Limit `comptime` to type construction | AI predicts simpler code |
| Optional chaining confusion | Explicit `orelse` over `.?` chains | AI sees null handling |
| Catch-all error handling | Exhaustive error switches required | AI handles all cases |
| `anytype` parameter ambiguity | Document `anytype` constraints in comments | AI knows type requirements |
| Packed struct portability | Avoid unless C interop required | AI generates portable code |
| Pointer arithmetic | Prefer slices over raw pointer math | AI generates bounds-safe code |
| Deferred cleanup confusion | One `defer` per resource, documented | AI understands cleanup order |
| `unreachable` misuse | Only for provably impossible states | AI doesn't hide bugs |

**Bug Pattern Prevention** (based on Tambon et al., 2025):

| Gizmo Rule | Prevents Bug Pattern |
|------------|---------------------|
| Allocator ownership docs | "Wrong Attribute," "Missing Corner Case" |
| Explicit error handling | "Missing Corner Case" |
| Document `anytype` | "Wrong Input Type," "Hallucinated Object" |
| No catch-all errors | "Missing Corner Case" |
| Explicit optionals | "Missing Corner Case," "Wrong Attribute" |
| Slice-first design | "Missing Corner Case" (bounds errors) |

## The Rules

### Rule 1: Document Allocator Ownership

```zig
// BANNED in Gizmo (ownership unclear)
pub fn createBuffer(allocator: std.mem.Allocator) ![]u8 {
    return allocator.alloc(u8, 1024);
}

// Gizmo: Document who frees
/// Creates a buffer of 1024 bytes.
///
/// OWNERSHIP: Caller owns returned memory. Must free with same allocator.
pub fn createBuffer(allocator: std.mem.Allocator) ![]u8 {
    return allocator.alloc(u8, 1024);
}
```

### Rule 2: Explicit Error Handling

```zig
// BANNED in Gizmo (error discarded silently)
const value = parseNumber(input) catch 0;

// Gizmo: Explicit error handling with documented fallback
const value = parseNumber(input) catch |err| blk: {
    // FALLBACK: Default to 0 on parse failure (expected for user input)
    log.debug("parse failed: {}, using default", .{err});
    break :blk 0;
};

// Or propagate with context
const value = parseNumber(input) catch |err| {
    return error.InvalidInput; // PROPAGATE: Caller handles
};
```

### Rule 3: Exhaustive Error Switches

```zig
// BANNED in Gizmo (catch-all hides cases)
fn handleError(err: anyerror) void {
    switch (err) {
        error.OutOfMemory => handleOom(),
        else => {}, // What errors are ignored?
    }
}

// Gizmo: All errors explicit
fn handleFileError(err: std.fs.File.OpenError) void {
    switch (err) {
        error.FileNotFound => log.err("file not found", .{}),
        error.AccessDenied => log.err("access denied", .{}),
        error.IsDir => log.err("path is a directory", .{}),
        // ... all other variants explicitly listed
        error.Unexpected => log.err("unexpected OS error", .{}),
    }
}
```

### Rule 4: Explicit Optional Handling

```zig
// BANNED in Gizmo (chained .? obscures null paths)
const name = user.?.profile.?.displayName.?;

// Gizmo: Explicit orelse with documented fallback
const name = blk: {
    const u = user orelse break :blk "anonymous"; // USER: null = anonymous
    const profile = u.profile orelse break :blk u.username; // PROFILE: fall back to username
    break :blk profile.displayName orelse u.username; // NAME: fall back to username
};
```

### Rule 5: Document `anytype` Constraints

```zig
// BANNED in Gizmo (what does T require?)
pub fn process(value: anytype) void {
    value.doSomething();
}

// Gizmo: Constraints documented
/// Processes any value that implements the Processor interface.
///
/// TYPE CONSTRAINT: `value` must have:
/// - `fn doSomething(self: @This()) void`
/// - `fn cleanup(self: @This()) void`
pub fn process(value: anytype) void {
    value.doSomething();
}
```

### Rule 6: Limit `comptime` to Type Construction

```zig
// BANNED in Gizmo (complex comptime logic)
pub fn computeValue(comptime n: usize) comptime_int {
    comptime {
        var result: comptime_int = 0;
        for (0..n) |i| {
            result += fibonacci(i); // Complex comptime computation
        }
        return result;
    }
}

// Gizmo: comptime for types and static assertions only
pub fn Matrix(comptime rows: usize, comptime cols: usize) type {
    return struct {
        data: [rows][cols]f64,

        // TYPE CONSTRUCTION: comptime used only for type shape
        pub fn identity() @This() {
            comptime std.debug.assert(rows == cols); // STATIC ASSERT: OK
            // ...
        }
    };
}
```

### Rule 7: One `defer` Per Resource

```zig
// BANNED in Gizmo (cleanup order unclear)
fn processFile(path: []const u8) !void {
    const file = try std.fs.openFile(path, .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(buffer); // Which defer runs first?

    // More code with more defers...
}

// Gizmo: Structured cleanup with clear ownership
fn processFile(allocator: std.mem.Allocator, path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close(); // CLEANUP[2]: File closed last (LIFO order)

    const buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(buffer); // CLEANUP[1]: Buffer freed first

    // Gizmo: Number indicates execution order (LIFO - last defer runs first)
}
```

### Rule 8: Prefer Slices Over Pointer Arithmetic

```zig
// BANNED in Gizmo (raw pointer math)
fn sumArray(ptr: [*]const i32, len: usize) i32 {
    var sum: i32 = 0;
    var i: usize = 0;
    while (i < len) : (i += 1) {
        sum += ptr[i]; // No bounds checking
    }
    return sum;
}

// Gizmo: Slices for bounds safety
fn sumArray(items: []const i32) i32 {
    var sum: i32 = 0;
    for (items) |item| {
        sum += item; // Bounds-checked iteration
    }
    return sum;
}
```

### Rule 9: `unreachable` Only for Provably Impossible States

```zig
// BANNED in Gizmo (hiding potential bugs)
fn getStatus(code: u8) Status {
    return switch (code) {
        0 => .idle,
        1 => .running,
        2 => .complete,
        else => unreachable, // What if code is 3?
    };
}

// Gizmo: Explicit error for unexpected values
const StatusError = error{InvalidStatusCode};

fn getStatus(code: u8) StatusError!Status {
    return switch (code) {
        0 => .idle,
        1 => .running,
        2 => .complete,
        else => error.InvalidStatusCode, // EXPLICIT: Unknown codes are errors
    };
}

// unreachable OK only for provably impossible states:
fn divideNonZero(a: u32, b: u32) u32 {
    std.debug.assert(b != 0); // Precondition established
    return a / b; // Division by zero impossible after assert
}
```

### Rule 10: Avoid Packed Structs Unless Required

```zig
// BANNED in Gizmo (unnecessary packing)
const Config = packed struct {
    flags: u8,
    version: u16,
    // Packed without reason - portability issues
};

// Gizmo: Regular struct unless C interop required
const Config = struct {
    flags: u8,
    version: u16,
    // Normal struct - portable, predictable
};

// Packed OK only for external formats:
/// Network packet header (must match wire format exactly).
/// C INTEROP: Matches network byte layout for sendto()
const PacketHeader = packed struct {
    version: u4,
    header_len: u4,
    // ... documented external format requirement
};
```

## Scorecard

| Dimension | Zig | Gizmo | Improvement |
|-----------|-----|-------|-------------|
| Typing | 4/5 | 4/5 | Same (strong compile-time types) |
| Explicit | 5/5 | 5/5 | Rules reinforce existing strength |
| Simplicity | 3/5 | 4/5 | Reduced `comptime` complexity |
| Error Handling | 4/5 | 5/5 | All errors visibly handled |
| Ecosystem | 2/5 | 2/5 | Same (growing but small) |
| **Total** | **72/100** | **80/100** | **+8 points** *(theoretical, unvalidated)* |

*Scores are theoretical projections based on documented failure modes and general LLM research. They have **not been empirically validated** for Zig specifically. See the [full paper](../Amphigraphic_Language_Guide.md) for methodology and research references.*

## Files in This Directory

- `build.zig.example` — Example build configuration with Gizmo-recommended settings
- `prompt.md` — AI system prompt template
- `examples/before.zig` — Common AI mistakes in Zig
- `examples/after.zig` — Gizmo-compliant versions

## Zig's Existing AI-Friendly Properties

Zig is already more explicit than most languages. Gizmo builds on these strengths:

| Zig Design | AI Benefit |
|------------|------------|
| No hidden control flow | AI can trace all execution paths |
| No hidden allocations | AI knows where memory is allocated |
| Explicit error unions | AI sees all error types |
| No operator overloading | AI knows what operators do |
| No garbage collection | AI understands memory lifetime |
| `comptime` vs runtime clear | AI knows what's computed when |

Gizmo adds documentation requirements and restricts patterns that remain ambiguous even with Zig's explicit design.

## Learn More

See the full [Amphigraphic Language Guide](../Amphigraphic_Language_Guide.md) for the complete rationale and additional patterns.
