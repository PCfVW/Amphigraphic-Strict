// before.cpp - Common AI mistakes in C++
// These patterns compile but contain subtle bugs that AI assistants frequently generate.
//
// Mistakes 1-3, 8-9 are addressed by Stoic's five core rules.
// Mistakes 4-7 are additional patterns documented for awareness.
// Mistakes 10-13 show patterns that need Stoic comment markers.

#include <cstdint>
#include <iostream>
#include <map>
#include <string>
#include <vector>

// --- MISTAKE 1: Manual Memory Management ---
// AI often forgets delete, especially in error paths

class ResourceManager {
    int* data;
    size_t size;

public:
    ResourceManager(size_t n) {
        data = new int[n];  // Raw new
        size = n;
    }

    void process() {
        if (size == 0) {
            return;  // BUG: Memory leak if we return early!
        }
        // ... processing ...
    }

    ~ResourceManager() {
        delete[] data;  // Only reached if destructor called
    }
};

// AI generates this pattern frequently:
void leakyFunction() {
    int* buffer = new int[100];

    if (someCondition()) {
        return;  // BUG: Memory leak!
    }

    process(buffer);
    delete[] buffer;  // Never reached if early return
}

// --- MISTAKE 2: Function-like Macros with Side Effects ---
// AI copies common macro patterns without understanding dangers

#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define SQUARE(x) ((x) * (x))

void macroProblems() {
    int x = 5;
    int y = 3;

    // BUG: x is incremented twice if x > y!
    int max_val = MAX(x++, y);

    // BUG: function called twice!
    int squared = SQUARE(expensiveComputation());
}

// --- MISTAKE 3: Constant Macros ---
// AI uses macros for constants instead of const variables

#define PI 3.14159265358979
#define BUFFER_SIZE 1024
#define ERROR_MESSAGE "An error occurred"

// Problems:
// - No type safety
// - No scope
// - Debugger shows "3.14159..." not "PI"
// - Can clash with other definitions

void useConstants() {
    double area = PI * radius * radius;  // Which PI? What type?
    char buffer[BUFFER_SIZE];  // Magic number in debugger
}

// --- MISTAKE 4: Header Complexity (simulated) ---
// AI doesn't understand include order dependencies

// In real code, this causes issues:
// #include "derived.h"  // Might fail if base.h not included first
// #include "base.h"     // Order matters!

// Macros from one header pollute another:
#define ERROR 1  // Some system header
#define SUCCESS 0

// Now any code including this file has ERROR and SUCCESS defined
// possibly conflicting with other definitions

// --- MISTAKE 5: Ownership Ambiguity ---
// AI generates ambiguous ownership patterns

class Container {
    Item* items;  // Who owns this? Who deletes it?
    int count;

public:
    Container() : items(nullptr), count(0) {}

    void add(Item* item) {
        // Does Container now own item? AI doesn't know.
        // If yes, who deletes the old items?
        // If no, what if caller deletes item while we hold it?
    }

    Item* get(int index) {
        return items + index;  // Caller might delete this!
    }

    ~Container() {
        delete[] items;  // Hope caller didn't delete individual items!
    }
};

// --- MISTAKE 6: Preprocessor Logic ---
// AI uses #ifdef for logic that should be compile-time evaluated

#define USE_FEATURE_X 1

void conditionalCode() {
#ifdef USE_FEATURE_X
    doFeatureX();
#else
    doAlternative();
#endif
    // Problem: Both branches must parse even if one is dead code
    // Problem: No type checking on inactive branch
    // Problem: Refactoring tools miss inactive code
}

// --- MISTAKE 7: Type Aliases via Macro ---
// AI sometimes uses macros for type definitions

#define StringList std::vector<std::string>
#define IntPair std::pair<int, int>

// Problems:
// - No template parameter support
// - Confusing error messages
// - Can't forward declare

// --- MISTAKE 8: Over-applying constexpr ---
// AI adds constexpr speculatively, causing compilation failures

// AI generates this — FAILS to compile:
constexpr std::string getName() {  // ERROR: std::string not constexpr-friendly (pre-C++20)
    return "hello";
}

// AI generates this — FAILS to compile:
constexpr std::vector<int> getNumbers() {  // ERROR: vector not constexpr (pre-C++20)
    return {1, 2, 3};
}

// AI generates this — FAILS if file is not available at compile-time:
constexpr auto config = parseConfigFile("config.json");  // ERROR: can't read file at compile-time

// AI adds constexpr to class with non-literal members:
class DataProcessor {
    std::string name;  // Non-literal type
public:
    constexpr DataProcessor(const char* n) : name(n) {}  // ERROR: can't be constexpr
};

// AI doesn't understand compile-time vs runtime context:
constexpr int compute(int x) { return x * 2; }
void runtimeFunction() {
    int userInput = getUserInput();
    constexpr int result = compute(userInput);  // ERROR: userInput not known at compile-time
}

// --- MISTAKE 9: Undocumented Preconditions and UB ---
// AI generates code that can trigger undefined behavior without warning

template<typename T>
class UnsafeContainer {
    T* data;
    size_t count;

public:
    // No documentation that index must be valid!
    T& at(size_t index) {
        return data[index];  // UB if index >= count
    }

    // No documentation that container must be non-empty!
    const T& front() const {
        return data[0];  // UB if count == 0
    }

    // AI often generates division without checking divisor
    T average() const {
        T sum = T{};
        for (size_t i = 0; i < count; ++i) sum += data[i];
        return sum / count;  // UB if count == 0 (division by zero)
    }
};

// AI generates code assuming valid input
void processIndex(const std::vector<int>& v, size_t index) {
    std::cout << v[index];  // UB if index >= v.size()
}

// AI forgets to check pointers
void processPointer(int* ptr) {
    *ptr = 42;  // UB if ptr is null
}

// --- MISTAKE 10: Undocumented Map Insertion via operator[] ---
// AI doesn't understand that operator[] inserts if key is missing

std::map<std::string, int> counters;

void incrementCounter(const std::string& name) {
    // BUG: If 'name' doesn't exist, this silently inserts 0, then increments to 1
    // AI thinks this just reads and increments, but it also mutates the map!
    counters[name]++;
}

int getCounter(const std::string& name) {
    // BUG: If 'name' doesn't exist, this inserts 0 and returns it
    // AI thinks this is a safe read, but it mutates the map!
    return counters[name];
}

// --- MISTAKE 11: Undocumented Intentional Copy ---
// AI might "optimize" this to const& and break the semantics

struct GameState {
    int score;
    std::vector<int> moves;
    void applyMove(int m) { moves.push_back(m); score += m; }
};

// AI sees pass-by-value and thinks "inefficient, should be const&"
// But the copy is INTENTIONAL for rollback semantics!
bool tryMove(GameState state, int move) {
    state.applyMove(move);
    if (state.score < 0) {
        return false;  // Original state unchanged - that's the point!
    }
    return true;
}

// --- MISTAKE 12: Undocumented Type Limits ---
// AI doesn't know the numeric constraints of these types

typedef unsigned char StepCount;    // What's the max? AI doesn't know
typedef std::uint8_t NodeId;        // What's the max? AI doesn't know

void planRoute(StepCount maxSteps) {
    // AI might generate code that exceeds 255 steps without realizing
    for (int i = 0; i < 1000; ++i) {  // BUG: loop exceeds StepCount max (255)!
        // AI doesn't know StepCount can only represent 0-255
    }
}

// --- MISTAKE 13: Undocumented Platform-Specific Code ---
// AI can't reason about which branch applies

#if defined(_MSC_VER)
    void platformSpecificInit() {
        // Windows-specific code
        // AI doesn't know this only runs on Windows
    }
#else
    void platformSpecificInit() {
        // Unix-specific code
        // AI doesn't know this only runs on Unix
    }
#endif

// Helper declarations for compilation
bool someCondition() { return false; }
void process(int*) {}
int expensiveComputation() { return 42; }
double radius = 1.0;
class Item {};
void doFeatureX() {}
void doAlternative() {}
int getUserInput() { return 42; }
// auto parseConfigFile(const char*) -> int { return 0; }  // Would need definition
