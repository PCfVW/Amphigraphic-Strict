# Gizmo AI System Prompt

Add this to your AI assistant's system prompt when working with Zig code.

---

## System Prompt Addition

```
When writing Zig, follow Gizmo (strict Zig) rules:

1. DOCUMENT allocator ownership in comments (OWNERSHIP: caller/callee frees)
2. NEVER silently discard errors - use explicit catch blocks with comments
3. SWITCH on specific error sets, never use `else` for errors without documenting why
4. USE explicit `orelse` with documented fallback, not chained `.?`
5. DOCUMENT `anytype` constraints in function comments (TYPE CONSTRAINT: must have...)
6. LIMIT `comptime` to type construction and static assertions only
7. ONE `defer` per resource with CLEANUP[n] order comments when order matters
8. PREFER slices over pointer arithmetic for bounds safety
9. USE `unreachable` only for provably impossible states, never to hide bugs
10. AVOID packed structs unless required for C interop (document with C INTEROP:)
```

---

## Extended Version (for complex projects)

```
When writing Zig, follow Gizmo (strict Zig) rules:

ALLOCATOR OWNERSHIP:
- DOCUMENT who owns returned memory: // OWNERSHIP: caller frees
- DOCUMENT who owns parameters: // BORROW: callee does not free
- PREFER passing allocator as first parameter
- USE errdefer to clean up on error paths

ERROR HANDLING:
- NEVER use catch without a block explaining the fallback
- SWITCH on specific error sets from the standard library
- AVOID `else` in error switches - list all variants explicitly
- ADD // PROPAGATE: or // FALLBACK: comments explaining error handling strategy
- USE error.* constants, not magic error codes

OPTIONAL HANDLING:
- USE explicit `orelse` with documented fallback values
- AVOID chained `.?` operators - break into named steps
- DOCUMENT null semantics: // NULL: means not initialized vs // NULL: means default

COMPTIME:
- LIMIT comptime to type construction: fn Matrix(comptime rows: usize) type
- USE comptime for static assertions: comptime std.debug.assert(N > 0)
- AVOID complex comptime loops or computations
- DOCUMENT comptime requirements: // COMPTIME: must be known at compile time

ANYTYPE PARAMETERS:
- DOCUMENT required interface in function doc comment
- LIST methods the type must have: TYPE CONSTRAINT: must have fn process(self) void
- PREFER concrete types or explicit interfaces when possible

RESOURCE CLEANUP:
- ONE defer statement per resource acquired
- COMMENT cleanup order when it matters: // CLEANUP[1]: closes file last
- USE errdefer for cleanup on error paths
- PREFER structured cleanup (init/deinit pairs) over scattered defers

MEMORY SAFETY:
- PREFER slices ([]T) over multi-pointers ([*]T)
- USE for loops over slices, not while loops with pointer arithmetic
- DOCUMENT pointer semantics when raw pointers are necessary
- PREFER sentinel-terminated slices ([:0]u8) for C strings

UNREACHABLE:
- ONLY use unreachable for mathematically provable impossibilities
- PREFER returning errors for "should not happen" cases
- ALWAYS have a preceding assertion or check that proves unreachability
- DOCUMENT why state is impossible: // UNREACHABLE: loop invariant guarantees i < len

PACKED STRUCTS:
- AVOID packed structs for internal data structures
- USE packed only for: C interop, network protocols, file formats
- DOCUMENT external format requirement: // C INTEROP: matches struct foo in header.h
- PREFER extern struct for C compatibility when packing not required

DOCUMENTATION:
- ADD doc comments (///) to all public functions
- DOCUMENT error conditions and ownership
- USE UPPERCASE tags: OWNERSHIP:, CLEANUP:, FALLBACK:, TYPE CONSTRAINT:, C INTEROP:
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
