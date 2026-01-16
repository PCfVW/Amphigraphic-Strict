// before.go - Common AI mistakes in Go
// These patterns compile but contain subtle bugs that AI assistants frequently generate.

package examples

import (
	"encoding/json"
	"fmt"
)

// --- MISTAKE 1: Type Erasure ---
// AI often uses interface{}/any when uncertain about types

func ProcessAny(data any) any {
	// AI doesn't know what type data is, generates incorrect handling
	return data
}

// --- MISTAKE 2: Ignored Errors ---
// AI frequently forgets to handle errors

func ReadConfig() map[string]string {
	data, _ := readFile("config.json") // Error silently ignored!
	result := make(map[string]string)
	json.Unmarshal(data, &result) // Another ignored error!
	return result
}

// --- MISTAKE 3: Named Returns with Bare Return ---
// AI generates confusing control flow

func Calculate(x int) (result int, err error) {
	if x < 0 {
		err = fmt.Errorf("negative input")
		return // What does this return? AI often gets confused
	}
	result = x * 2
	return // Implicit return of named values
}

// --- MISTAKE 4: Typed Nil Interface ---
// AI doesn't understand nil interface semantics

type MyError struct {
	msg string
}

func (e *MyError) Error() string { return e.msg }

func MightFail(fail bool) error {
	var err *MyError // nil pointer
	if fail {
		err = &MyError{msg: "failed"}
	}
	return err // BUG: Returns non-nil interface with nil value!
}

// --- MISTAKE 5: Goroutine Loop Variable Capture ---
// Classic AI mistake - closure captures loop variable by reference.
// Note: Go 1.22+ changed loop variable semantics, but this pattern remains
// problematic for (1) pre-1.22 codebases, (2) AI models trained on older code,
// and (3) code clarity.

func ProcessItems(items []string) {
	for _, item := range items {
		go func() {
			fmt.Println(item) // BUG (pre-Go 1.22): All goroutines print the last item!
		}()
	}
}

// --- MISTAKE 6: Nil Slice JSON Encoding ---
// AI doesn't know nil vs empty slice serialization difference

type Response struct {
	Items []string `json:"items"`
}

func GetItems(found bool) Response {
	var items []string // nil slice
	if found {
		items = append(items, "item1")
	}
	return Response{Items: items} // BUG: JSON encodes to {"items":null} not {"items":[]}
}

// --- MISTAKE 7: Error Without Context ---
// AI returns raw errors without wrapping

func FetchUser(id string) (User, error) {
	user, err := db.Find(id)
	if err != nil {
		return User{}, err // No context - where did this error come from?
	}
	return user, nil
}

// Helper types for compilation
type User struct{ Name string }

var db = struct {
	Find func(string) (User, error)
}{
	Find: func(id string) (User, error) { return User{}, nil },
}

func readFile(path string) ([]byte, error) { return nil, nil }
