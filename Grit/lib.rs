//! Grit: Strict Rust crate-level configuration
//!
//! Copy these deny directives to your lib.rs or main.rs

// === GRIT CRATE-LEVEL LINTS ===

// Rule 1: Explicit lifetimes on public APIs
#![deny(elided_lifetimes_in_paths)]

// Rule 3: No panics in library code (remove for binaries/tests)
#![deny(clippy::unwrap_used)]
#![deny(clippy::expect_used)]
#![deny(clippy::panic)]
#![deny(clippy::indexing_slicing)]

// Rule 4: No type erasure
// (enforced via code review - no lint available)

// Rule 5: Unsafe isolation
#![forbid(unsafe_code)] // Or #![deny(unsafe_code)] with isolated modules

// Rule 7: Exhaustive matching
#![deny(clippy::wildcard_enum_match_arm)]

// === ADDITIONAL STRICTNESS ===

// Explicit conversions preferred
#![warn(clippy::as_conversions)]

// Rule 9: Prefer iterators over loops
#![warn(clippy::explicit_iter_loop)]
#![warn(clippy::manual_filter_map)]
#![warn(clippy::manual_find_map)]
#![warn(clippy::needless_range_loop)]

// Documentation requirements
#![warn(missing_docs)]
#![warn(clippy::missing_docs_in_private_items)]
#![warn(clippy::missing_errors_doc)]
#![warn(clippy::missing_panics_doc)]

// General quality
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]

// === ALLOWED LINTS (too noisy) ===
#![allow(clippy::module_name_repetitions)]
#![allow(clippy::too_many_lines)]
#![allow(clippy::must_use_candidate)]

// === YOUR CODE STARTS HERE ===

/// Example module following Grit rules.
pub mod example {
    use std::collections::HashMap;

    /// Error type for user operations.
    #[derive(Debug)]
    pub enum UserError {
        /// User was not found in the database.
        NotFound,
        /// Database connection failed.
        DatabaseError(String),
    }

    /// User data structure.
    pub struct User {
        /// User's display name.
        pub name: String,
    }

    /// Fetches a user by ID.
    ///
    /// # Errors
    ///
    /// Returns `UserError::NotFound` if the user doesn't exist.
    /// Returns `UserError::DatabaseError` if the database query fails.
    pub fn get_user<'a>(
        users: &'a HashMap<String, User>,
        id: &str,
    ) -> Result<&'a User, UserError> {
        users.get(id).ok_or(UserError::NotFound)
    }
}
