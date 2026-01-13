// after.go - Cog-compliant versions
// These patterns follow Cog rules and eliminate the subtle bugs.

package examples

import (
	"encoding/json"
	"fmt"
)

// --- FIX 1: No Type Erasure - Use Generics ---

type Processor interface {
	Process() error
}

func ProcessTyped[T Processor](data T) error {
	// AI knows exact type, generates correct handling
	return data.Process()
}

// --- FIX 2: Explicit Error Handling ---

func ReadConfigSafe() (map[string]string, error) {
	data, err := readFile("config.json")
	if err != nil {
		return nil, fmt.Errorf("read config file: %w", err)
	}

	result := make(map[string]string)
	if err := json.Unmarshal(data, &result); err != nil {
		return nil, fmt.Errorf("parse config JSON: %w", err)
	}

	return result, nil
}

// --- FIX 3: No Named Returns - Explicit Values ---

func CalculateSafe(x int) (int, error) {
	if x < 0 {
		return 0, fmt.Errorf("negative input: %d", x)
	}
	return x * 2, nil // Crystal clear what's returned
}

// --- FIX 4: Bare Nil for Interfaces ---

type SafeError struct {
	msg string
}

func (e *SafeError) Error() string { return e.msg }

func MightFailSafe(fail bool) error {
	if fail {
		return &SafeError{msg: "failed"}
	}
	return nil // Always bare nil - no typed nil confusion
}

// --- FIX 5: Pass Loop Variables as Arguments ---

func ProcessItemsSafe(items []string) {
	for _, item := range items {
		go func(it string) { // CAPTURE: loop variable passed as argument
			fmt.Println(it) // Each goroutine has its own copy
		}(item)
	}
}

// --- FIX 6: Explicit Empty Slice Initialization ---

type SafeResponse struct {
	Items []string `json:"items"`
}

func GetItemsSafe(found bool) SafeResponse {
	items := make([]string, 0) // EMPTY SLICE: JSON encodes to []
	if found {
		items = append(items, "item1")
	}
	return SafeResponse{Items: items} // Always {"items":[...]}
}

// --- FIX 7: Errors with Context ---

func FetchUserSafe(id string) (User, error) {
	user, err := db.Find(id)
	if err != nil {
		return User{}, fmt.Errorf("fetch user %s: %w", id, err) // Traceable!
	}
	return user, nil
}

// --- BONUS: Result Type Pattern ---

type Result[T any] struct {
	value T
	err   error
	ok    bool
}

func Ok[T any](v T) Result[T]      { return Result[T]{value: v, ok: true} }
func Err[T any](e error) Result[T] { return Result[T]{err: e, ok: false} }

func (r Result[T]) Unwrap() (T, error) {
	if !r.ok {
		return r.value, r.err
	}
	return r.value, nil
}

func FetchUserResult(id string) Result[User] {
	user, err := db.Find(id)
	if err != nil {
		return Err[User](fmt.Errorf("fetch user %s: %w", id, err))
	}
	return Ok(user)
}
