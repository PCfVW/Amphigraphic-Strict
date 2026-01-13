# Amphigraphic Strict Subsets

Ready-to-use linter configs and AI prompts for **Cog** (Go), **Grit** (Rust), and **Terse** (TypeScript) — strict language subsets designed for AI-assisted development.

**What you get:** Linter configs and AI prompts that enforce coding patterns designed to reduce common AI generation errors. The scoring framework helps communicate *why* certain language features cause AI mistakes, but the real value is in the enforceable rules.

**Based on the paper:** [Amphigraphic Language Guide](Amphigraphic_Language_Guide.md)

## Why Strict Subsets?

AI coding assistants predict "most likely" code, but many language features allow multiple valid interpretations. The strict subsets improve AI accuracy by reducing ambiguity:

| Subset | Base Language | Base Score | Strict Score | Improvement |
|--------|---------------|------------|--------------|-------------|
| **Cog** | Go | 84/100 | 96/100 | +12 points |
| **Terse** | TypeScript | 76/100 | 92/100 | +16 points |
| **Grit** | Rust | 84/100 | 92/100 | +8 points |

*Note: Scores are proposed estimates based on documented failure modes, not empirically measured values. See the [full paper](Amphigraphic_Language_Guide.md) for methodology.*

## Quick Start

First, clone this repository:
```bash
git clone https://github.com/your-org/Amphigraphic-Strict.git
cd Amphigraphic-Strict
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

## AI Prompts

Each subset includes a `prompt.md` with system prompt additions for Claude, Cursor, Copilot, or other AI assistants.

- [Cog/prompt.md](Cog/prompt.md) — Go AI rules
- [Grit/prompt.md](Grit/prompt.md) — Rust AI rules
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
├── Grit/                          # Strict Rust
│   ├── README.md
│   ├── Cargo.toml                 # [lints] section to copy
│   ├── lib.rs                     # #![deny(...)] template
│   ├── prompt.md
│   └── examples/
│       ├── before.rs
│       └── after.rs
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
