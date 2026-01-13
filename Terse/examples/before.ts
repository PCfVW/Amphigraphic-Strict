// before.ts - Common AI mistakes in TypeScript
// These patterns compile but contain subtle bugs that AI assistants frequently generate.

// --- MISTAKE 1: Using `any` Type ---
// AI uses any when uncertain about types

function processData(data: any): any {
  // AI can't know what operations are valid
  return data.transform();
}

function handleEvent(event: any) {
  // Lost all type information
  console.log(event.target.value);
}

// --- MISTAKE 2: Type Assertions (`as`) ---
// AI uses assertions to "fix" type errors without verifying

interface User {
  id: string;
  name: string;
  email: string;
}

function parseUser(json: string): User {
  const data = JSON.parse(json);
  return data as User; // BUG: No validation! Could be anything
}

function getElement(): HTMLInputElement {
  const el = document.getElementById('input');
  return el as HTMLInputElement; // BUG: Could be null or wrong type
}

// --- MISTAKE 3: Non-null Assertions (!) ---
// AI uses ! to silence null warnings

function getUserName(user: User | null): string {
  return user!.name; // BUG: Will crash if null!
}

function getFirstItem<T>(items: T[]): T {
  return items[0]!; // BUG: Will crash if empty!
}

// --- MISTAKE 4: Missing Return Types ---
// AI often omits return types, leading to inference issues

function fetchUser(id: string) {
  // Return type inferred - AI might misunderstand
  return fetch(`/users/${id}`).then((r) => r.json());
}

const getConfig = () => {
  // Return type inferred from implementation
  return { timeout: 1000, retries: 3 };
};

// --- MISTAKE 5: Unsafe Index Access ---
// AI assumes array access always succeeds

function processItems(items: string[]) {
  const first = items[0]; // Type is string, but could be undefined!
  console.log(first.toUpperCase()); // BUG: Crashes on empty array
}

function getValue(record: Record<string, number>, key: string) {
  const value = record[key]; // Type is number, but could be undefined!
  return value * 2; // BUG: NaN if key doesn't exist
}

// --- MISTAKE 6: Narrowing Lost After Await ---
// AI forgets that narrowing is invalidated by async operations

async function processUser(user: User | null) {
  if (user === null) return;

  // user is narrowed to User here...
  await saveToDatabase(user);

  // ...but technically could be reassigned during await
  console.log(user.name); // TypeScript allows, but pattern is fragile
}

// --- MISTAKE 7: Using Enums ---
// AI generates enums which have complex runtime behavior

enum Status {
  Active = 'ACTIVE',
  Pending = 'PENDING',
  Cancelled = 'CANCELLED',
}

// Enums can be iterated, have reverse mappings, etc.
// This complexity confuses AI about runtime behavior

// --- MISTAKE 8: Unclear Spread Order ---
// AI generates spreads without documenting priority

interface Config {
  timeout: number;
  retries: number;
  debug: boolean;
}

function mergeConfig(
  defaults: Config,
  overrides: Partial<Config>
): Config {
  return { ...defaults, ...overrides }; // Which wins? Not obvious
}

// --- MISTAKE 9: Throwing Exceptions ---
// AI throws instead of using type-safe error handling

function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Division by zero'); // Caller can forget to catch!
  }
  return a / b;
}

async function fetchData(url: string): Promise<Data> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`); // Type system doesn't track this
  }
  return response.json();
}

// Helper types
interface Data {
  value: string;
}

async function saveToDatabase(user: User): Promise<void> {
  // Implementation
}
