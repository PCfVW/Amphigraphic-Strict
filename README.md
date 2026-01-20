# Amphigraphic Strict Subsets

Ready-to-use linter configs and AI prompts for **Cog** (Go), **Gizmo** (Zig), **Grit** (Rust), **Stoic** (C++), and **Terse** (TypeScript) — strict language subsets designed for AI-assisted development.

**What you get:** Linter configs and AI prompts that enforce coding patterns designed to reduce common AI generation errors. The scoring framework helps communicate *why* certain language features cause AI mistakes, but the real value is in the enforceable rules.

**Based on the paper:** [Amphigraphic Language Guide](Amphigraphic_Language_Guide.md)

## Why Strict Subsets?

AI coding assistants predict "most likely" code, but many language features allow multiple valid interpretations. The strict subsets improve AI accuracy by reducing ambiguity:

| Subset | Base Language | Base Score | Strict Score | Improvement | Validation Status |
|--------|---------------|------------|--------------|-------------|-------------------|
| **Terse** | TypeScript | 76/100 | 92/100 | +16 points | **Empirically validated** |
| **Cog** | Go | 84/100 | 96/100 | +12 points | Theoretical (inferred) |
| **Gizmo** | Zig | 72/100 | 80/100 | +8 points | Theoretical (inferred) |
| **Grit** | Rust | 84/100 | 92/100 | +8 points | Theoretical (inferred) |
| **Stoic** | C++ | 56/100 | 64/100 | +8 points | Theoretical (inferred) |

**Validation status explained:**
- **Terse (TypeScript):** Direct empirical support from Mündler et al. [PLDI 2025], which demonstrated 74.8%/56.0% compilation error reduction with TypeScript type constraints.
- **Cog (Go), Gizmo (Zig), Grit (Rust) & Stoic (C++):** Rules are inferred from general LLM error research (e.g., 33.6% of failures are type errors). No language-specific validation studies exist yet—this is an open research opportunity.

*See the [full paper](Amphigraphic_Language_Guide.md) for detailed methodology and all 15 research references.*

## Empirical Validation: Three-Level Hierarchy Study

The theoretical recommendations in this guide have been empirically tested in the [d-Heap Priority Queue experiment](https://github.com/PCfVW/d-Heap-priority-queue/tree/master/experiment). Key findings:

| Hypothesis | Prediction | Result |
|------------|------------|--------|
| Type signatures constrain output | Types < Docs < Baseline | ✅ **Confirmed**: -23% tokens, +23 points API conformance |
| Documentation helps | Docs < Baseline | ❌ **Contradicted**: Docs ≈ Baseline (+1.6%) |
| Combined context is best | Combined < All | ❌ **Contradicted**: Combined = worst (+5.4%) |

**New discoveries:**
- **Prompt structure matters**: `@import("module")` triggers test suppression; inline presentation triggers 100% preservation
- **Model tier matters**: Opus interprets tests as specs; Sonnet/Haiku 4.5 preserves them verbatim
- **100% test preservation**: Rust, Zig (inline), and Python doctests achieve perfect preservation with Sonnet

**Practical implication**: Provide type signatures, not documentation. For inline-test languages (Rust, Zig), include example tests inline for 100% preservation.

See the [full experiment](https://github.com/PCfVW/d-Heap-priority-queue/blob/master/experiment/results/three_level_hypothesis_findings.md) for methodology and complete data.

## Quick Start

First, clone this repository:
```bash
git clone https://github.com/PCfVW/Amphigraphic-Strict.git
cd Amphigraphic-Strict
```

### C++ → Stoic
```bash
# Linux/macOS
cp Stoic/.clang-tidy your-project/

# Windows
copy Stoic\.clang-tidy your-project\

# Then run clang-tidy
clang-tidy -p build/ --config-file=.clang-tidy src/*.cpp
```

### Go → Cog
```bash
# Linux/macOS
cp Cog/.golangci.yml your-project/

# Windows
copy Cog\.golangci.yml your-project\

# Then run the linter
golangci-lint run ./...
```

### Rust → Grit
```bash
# Copy the [lints] section from Grit/Cargo.toml to your project's Cargo.toml
# Then run clippy
cargo clippy -- -D warnings
```

### TypeScript → Terse
```bash
# Linux/macOS
cp Terse/tsconfig.json Terse/eslint.config.js your-project/

# Windows
copy Terse\tsconfig.json your-project\
copy Terse\eslint.config.js your-project\

# Install dependencies and run
npm install -D eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser
npx eslint . --ext .ts,.tsx
```

### Zig → Gizmo
```bash
# Copy the build.zig.example settings to your project's build.zig
# (Gizmo uses standard Zig with strict conventions)

# Run tests with all safety checks
zig build test

# Build with release-safe for production (keeps safety checks)
zig build -Doptimize=ReleaseSafe
```

## AI Prompts

Each subset includes a `prompt.md` with system prompt additions for Claude, Cursor, Copilot, or other AI assistants.

- [Cog/prompt.md](Cog/prompt.md) — Go AI rules
- [Gizmo/prompt.md](Gizmo/prompt.md) — Zig AI rules
- [Grit/prompt.md](Grit/prompt.md) — Rust AI rules
- [Stoic/prompt.md](Stoic/prompt.md) — C++ AI rules
- [Terse/prompt.md](Terse/prompt.md) — TypeScript AI rules

## Repository Structure

```
Amphigraphic-Strict/
├── README.md                      # This file
├── LICENSE                        # Apache 2.0
├── Amphigraphic_Language_Guide.md # Full paper
│
├── Cog/                           # Strict Go
│   ├── README.md                  # Cog rationale + quick start
│   ├── .golangci.yml              # Ready to copy
│   ├── prompt.md                  # AI system prompt template
│   └── examples/
│       ├── before.go              # Common AI mistakes
│       └── after.go               # Cog-compliant version
│
├── Gizmo/                         # Strict Zig
│   ├── README.md
│   ├── build.zig.example          # Example build configuration
│   ├── prompt.md
│   └── examples/
│       ├── before.zig
│       └── after.zig
│
├── Grit/                          # Strict Rust
│   ├── README.md
│   ├── Cargo.toml                 # [lints] section to copy
│   ├── lib.rs                     # #![deny(...)] template
│   ├── prompt.md
│   └── examples/
│       ├── before.rs
│       └── after.rs
│
├── Stoic/                         # Strict C++
│   ├── README.md
│   ├── .clang-tidy                # Ready to copy
│   ├── prompt.md
│   └── examples/
│       ├── before.cpp
│       └── after.cpp
│
├── Terse/                         # Strict TypeScript
│   ├── README.md
│   ├── tsconfig.json              # Ready to copy
│   ├── eslint.config.js           # Ready to copy
│   ├── prompt.md
│   └── examples/
│       ├── before.ts
│       └── after.ts
│
└── docs/                          # Deeper explanations
    ├── scoring-rubric.md          # The 5-dimension framework
    └── failure-modes.md           # Expanded examples from paper
```

## Contributing

- Found a conflict with a popular library? Open an issue.
- Have an improvement? PRs welcome.
- Want to add another language subset? See the [scoring rubric](docs/scoring-rubric.md).

## License

Apache 2.0 — See [LICENSE](LICENSE)
