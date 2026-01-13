// Terse: Strict TypeScript ESLint configuration
// Requires: npm install -D eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser

import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        project: true,
      },
    },
    rules: {
      // === RULE 1: NO ESCAPE HATCHES ===

      // Ban `any` type
      '@typescript-eslint/no-explicit-any': 'error',

      // Ban non-null assertions (!)
      '@typescript-eslint/no-non-null-assertion': 'error',

      // Ban `as` type assertions - use type guards instead
      '@typescript-eslint/consistent-type-assertions': [
        'error',
        {
          assertionStyle: 'never',
        },
      ],

      // Ban @ts-ignore and @ts-nocheck
      '@typescript-eslint/ban-ts-comment': [
        'error',
        {
          'ts-expect-error': 'allow-with-description',
          'ts-ignore': true,
          'ts-nocheck': true,
          'ts-check': false,
        },
      ],

      // === RULE 2: EXPLICIT RETURN TYPES ===

      '@typescript-eslint/explicit-function-return-type': [
        'error',
        {
          allowExpressions: true, // Allow in callbacks
          allowTypedFunctionExpressions: true,
          allowHigherOrderFunctions: true,
          allowDirectConstAssertionInArrowFunctions: true,
        },
      ],

      // Explicit module boundary types
      '@typescript-eslint/explicit-module-boundary-types': 'error',

      // === RULE 5: NO ENUMS ===

      'no-restricted-syntax': [
        'error',
        {
          selector: 'TSEnumDeclaration',
          message:
            'Terse: Use union types instead of enums. Example: type Status = "active" | "pending"',
        },
      ],

      // === PROMISE SAFETY ===

      // No floating promises (unhandled)
      '@typescript-eslint/no-floating-promises': 'error',

      // No misused promises (in conditions, etc.)
      '@typescript-eslint/no-misused-promises': 'error',

      // Ensure awaited values are thenable
      '@typescript-eslint/await-thenable': 'error',

      // Require Promise rejection handling
      '@typescript-eslint/promise-function-async': 'error',

      // === ADDITIONAL STRICTNESS ===

      // Prefer nullish coalescing over ||
      '@typescript-eslint/prefer-nullish-coalescing': 'error',

      // Prefer optional chaining
      '@typescript-eslint/prefer-optional-chain': 'error',

      // No unnecessary conditions
      '@typescript-eslint/no-unnecessary-condition': 'error',

      // Strict boolean expressions
      '@typescript-eslint/strict-boolean-expressions': [
        'error',
        {
          allowString: false,
          allowNumber: false,
          allowNullableObject: true,
          allowNullableBoolean: false,
          allowNullableString: false,
          allowNullableNumber: false,
          allowAny: false,
        },
      ],

      // Require switch exhaustiveness
      '@typescript-eslint/switch-exhaustiveness-check': 'error',

      // === GENERAL QUALITY ===

      // Consistent type imports
      '@typescript-eslint/consistent-type-imports': [
        'error',
        { prefer: 'type-imports' },
      ],

      // No unused variables
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_' },
      ],

      // Prefer readonly
      '@typescript-eslint/prefer-readonly': 'error',
    },
  },
  {
    // Relaxed rules for test files
    files: ['**/*.test.ts', '**/*.spec.ts', '**/__tests__/**'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/consistent-type-assertions': 'off',
    },
  }
);
