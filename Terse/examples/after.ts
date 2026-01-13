// after.ts - Terse-compliant versions
// These patterns follow Terse rules and eliminate the subtle bugs.

// --- FIX 1: Use `unknown` with Type Guards ---
// Terse: Never use any, always validate with type guards

interface Transformable {
  transform(): string;
}

// NOTE: Type guards require internal `as` casts to access properties on unknown.
// This is the ONE exception to the "no as" rule - it's unavoidable in type guards.
function isTransformable(value: unknown): value is Transformable {
  return (
    typeof value === 'object' &&
    value !== null &&
    'transform' in value &&
    typeof (value as { transform: unknown }).transform === 'function'
  );
}

function processDataSafe(data: unknown): string | null {
  if (isTransformable(data)) {
    return data.transform();
  }
  return null;
}

// --- FIX 2: Type Guards Instead of Assertions ---
// Terse: Validate data, don't assert

interface User {
  readonly id: string;
  readonly name: string;
  readonly email: string;
}

function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    typeof (value as { id: unknown }).id === 'string' &&
    'name' in value &&
    typeof (value as { name: unknown }).name === 'string' &&
    'email' in value &&
    typeof (value as { email: unknown }).email === 'string'
  );
}

function parseUserSafe(json: string): User | null {
  try {
    const data: unknown = JSON.parse(json);
    if (isUser(data)) {
      return data;
    }
    return null;
  } catch {
    return null;
  }
}

function getInputElement(id: string): HTMLInputElement | null {
  const el = document.getElementById(id);
  if (el instanceof HTMLInputElement) {
    return el;
  }
  return null;
}

// --- FIX 3: Explicit Null Checks ---
// Terse: Handle null explicitly, never use !

function getUserNameSafe(user: User | null): string | null {
  if (user === null) {
    return null;
  }
  return user.name;
}

function getFirstItemSafe<T>(items: readonly T[]): T | undefined {
  return items[0]; // With noUncheckedIndexedAccess, type is T | undefined
}

// --- FIX 4: Explicit Return Types ---
// Terse: All functions have explicit return types

async function fetchUserTyped(id: string): Promise<User | null> {
  const response = await fetch(`/users/${id}`);
  if (!response.ok) {
    return null;
  }
  const data: unknown = await response.json();
  if (isUser(data)) {
    return data;
  }
  return null;
}

interface AppConfig {
  readonly timeout: number;
  readonly retries: number;
}

const getConfigTyped = (): AppConfig => {
  return { timeout: 1000, retries: 3 };
};

// --- FIX 5: Safe Index Access ---
// Terse: Always handle undefined from index access

function processItemsSafe(items: readonly string[]): void {
  const first = items[0]; // Type is string | undefined
  if (first !== undefined) {
    console.log(first.toUpperCase());
  }
}

function getValueSafe(
  record: Readonly<Record<string, number>>,
  key: string
): number | undefined {
  const value = record[key]; // Type is number | undefined
  if (value === undefined) {
    return undefined;
  }
  return value * 2;
}

// --- FIX 6: Capture Narrowed Values Before Await ---
// Terse: Assign narrowed values to const before async boundaries

async function processUserSafe(user: User | null): Promise<void> {
  if (user === null) {
    return;
  }

  const validUser = user; // NARROWED: captured before async boundary
  await saveToDatabase(validUser);

  // validUser is guaranteed to be User
  console.log(validUser.name);
}

// --- FIX 7: Union Types Instead of Enums ---
// Terse: Use union types for predictable behavior

type Status = 'active' | 'pending' | 'cancelled';

const STATUS = {
  Active: 'active',
  Pending: 'pending',
  Cancelled: 'cancelled',
} as const;

type StatusFromConst = (typeof STATUS)[keyof typeof STATUS];

function handleStatus(status: Status): string {
  switch (status) {
    case 'active':
      return 'User is active';
    case 'pending':
      return 'User is pending';
    case 'cancelled':
      return 'User is cancelled';
  }
  // TypeScript ensures exhaustiveness - no default needed
}

// --- FIX 8: Document Spread Order ---
// Terse: Comment merge priority explicitly

interface Config {
  readonly timeout: number;
  readonly retries: number;
  readonly debug: boolean;
}

function mergeConfigSafe(
  defaults: Config,
  overrides: Partial<Config>
): Config {
  return {
    ...defaults, // PRIORITY 1: base values
    ...overrides, // PRIORITY 2: overrides win
  };
}

// --- FIX 9: Result Type Instead of Exceptions ---
// Terse: Use type-safe error handling

type Result<T, E = Error> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: E };

function Ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function Err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

type DivisionError = { readonly code: 'DIVISION_BY_ZERO' };

function divideSafe(a: number, b: number): Result<number, DivisionError> {
  if (b === 0) {
    return Err({ code: 'DIVISION_BY_ZERO' });
  }
  return Ok(a / b);
}

type FetchError =
  | { readonly code: 'NETWORK_ERROR'; readonly cause: unknown }
  | { readonly code: 'HTTP_ERROR'; readonly status: number }
  | { readonly code: 'PARSE_ERROR' };

interface Data {
  readonly value: string;
}

function isData(value: unknown): value is Data {
  return (
    typeof value === 'object' &&
    value !== null &&
    'value' in value &&
    typeof (value as { value: unknown }).value === 'string'
  );
}

async function fetchDataSafe(url: string): Promise<Result<Data, FetchError>> {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      return Err({ code: 'HTTP_ERROR', status: response.status });
    }
    const data: unknown = await response.json();
    if (isData(data)) {
      return Ok(data);
    }
    return Err({ code: 'PARSE_ERROR' });
  } catch (error: unknown) {
    return Err({ code: 'NETWORK_ERROR', cause: error });
  }
}

// Usage - error handling is enforced by types
async function example(): Promise<void> {
  const result = await fetchDataSafe('https://api.example.com/data');

  if (!result.ok) {
    switch (result.error.code) {
      case 'NETWORK_ERROR':
        console.error('Network failed:', result.error.cause);
        break;
      case 'HTTP_ERROR':
        console.error('HTTP error:', result.error.status);
        break;
      case 'PARSE_ERROR':
        console.error('Invalid response format');
        break;
    }
    return;
  }

  // result.value is safely Data here
  console.log(result.value.value);
}

// Helper function
async function saveToDatabase(user: User): Promise<void> {
  // Implementation
}
