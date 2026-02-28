// after.rs - Grit-compliant versions
// These patterns follow Grit rules and eliminate the subtle bugs.

use std::collections::HashMap;
use std::io::BufWriter;
use std::net::TcpStream;

// --- FIX 1: Explicit Lifetimes ---
// Grit: All public functions show lifetime relationships

impl User {
    /// Returns the user's name.
    /// The returned reference borrows from self.
    pub fn get_name<'a>(&'a self) -> &'a str {
        &self.name
    }
}

/// Parses the first segment before ':'.
/// The returned reference borrows from the input string.
pub fn parse<'a>(input: &'a str) -> Option<&'a str> {
    input.split(':').next()
}

// --- FIX 2: Explicit Conversions ---
// Grit: Never rely on implicit Deref

fn process_str(s: &str) {
    println!("{}", s);
}

fn use_string_explicit() {
    let string = String::from("hello");
    process_str(string.as_str()); // EXPLICIT: clear what's being passed

    // Other explicit conversions
    let bytes: &[u8] = string.as_bytes(); // EXPLICIT
    let owned: String = "borrowed".to_owned(); // EXPLICIT
}

// --- FIX 3: Error Propagation Instead of Panic ---
// Grit: Library code propagates errors

#[derive(Debug)]
pub enum UserError {
    NotFound,
    ParseError(String),
    EmptyCollection,
}

/// Gets a user by ID.
///
/// # Errors
/// Returns `UserError::NotFound` if the user doesn't exist.
pub fn get_user<'a>(
    users: &'a HashMap<String, User>,
    id: &str,
) -> Result<&'a User, UserError> {
    users.get(id).ok_or(UserError::NotFound)
}

/// Parses a number from string.
///
/// # Errors
/// Returns `UserError::ParseError` if the input is not a valid number.
pub fn parse_number(input: &str) -> Result<i32, UserError> {
    input
        .parse()
        .map_err(|e| UserError::ParseError(format!("{}", e)))
}

/// Gets the first item from a vector.
///
/// # Errors
/// Returns `UserError::EmptyCollection` if the vector is empty.
pub fn first_item<T>(vec: &[T]) -> Result<&T, UserError> {
    vec.first().ok_or(UserError::EmptyCollection)
}

// --- FIX 4: Generics Instead of Type Erasure ---
// Grit: Use generics to preserve type information

trait Item {
    fn process(&self);
}

fn store_typed<T: Item>(item: T) {
    // Full type information available
    item.process();
}

fn process_static<F: Fn()>(handler: F) {
    // Static dispatch - monomorphized, faster, type-safe
    handler();
}

// TRAIT_OBJECT: Required for heterogeneous collection
fn register_handlers(handlers: Vec<Box<dyn Fn()>>) {
    // Dynamic dispatch justified and documented
    for handler in handlers {
        handler();
    }
}

// --- FIX 5: Isolated Unsafe with Safety Documentation ---
// Grit: Unsafe code in dedicated module with clear documentation

mod unsafe_ops {
    //! Unsafe operations with documented safety requirements.

    /// Reads a u32 from a byte slice.
    ///
    /// # Safety
    ///
    /// - `data` must be at least 4 bytes long
    /// - `data` must be properly aligned for u32
    /// - The bytes must represent a valid u32 in native endianness
    pub unsafe fn read_u32(data: &[u8]) -> u32 {
        debug_assert!(data.len() >= 4, "data too short");
        std::ptr::read(data.as_ptr() as *const u32)
    }
}

fn transmute_data_safe(data: &[u8]) -> Result<u32, &'static str> {
    if data.len() < 4 {
        return Err("data too short");
    }
    // SAFETY: We verified length >= 4, assuming proper alignment
    Ok(unsafe { unsafe_ops::read_u32(data) })
}

// --- FIX 6: Owned Types in Async ---
// Grit: Async functions take owned types to avoid lifetime complexity

/// User data structure.
#[derive(Clone)]
pub struct User {
    name: String,
}

/// Database handle (clone-friendly).
#[derive(Clone)]
pub struct Db;

impl Db {
    pub async fn find(&self, _id: &str) -> Option<User> {
        None
    }
}

/// Fetches a user by ID.
///
/// # Errors
/// Returns error if user not found.
pub async fn fetch_user(db: Db, id: String) -> Result<User, UserError> {
    // Owned types - no lifetime complexity
    db.find(&id).await.ok_or(UserError::NotFound)
}

/// Processes data and returns owned result.
pub async fn process_data(data: String) -> String {
    // Owned in, owned out - clean async signature
    format!("processed: {}", data)
}

// --- FIX 7: Exhaustive Matching ---
// Grit: All variants explicitly handled

#[derive(Debug)]
pub enum Status {
    Active,
    Pending,
    Cancelled,
    Expired,
}

fn handle_status(status: Status) {
    match status {
        Status::Active => println!("Active!"),
        Status::Pending => {} // EXPLICIT: pending needs no action
        Status::Cancelled => {} // EXPLICIT: cancelled needs no action
        Status::Expired => {} // EXPLICIT: expired needs no action
    }
}

// Alternative: grouped handling with documentation
fn handle_status_grouped(status: Status) {
    match status {
        Status::Active => println!("Active!"),
        // INACTIVE_STATES: All non-active states handled identically
        Status::Pending | Status::Cancelled | Status::Expired => {
            println!("Not active");
        }
    }
}

// --- FIX 8: Documented Drop Order ---
// Grit: Destruction order dependencies are documented

/// Connection with buffered writer.
///
/// # Drop Order
///
/// Fields drop in declaration order:
/// 1. `writer` - flushes buffered data
/// 2. `stream` - closes the TCP connection
///
/// This order ensures buffered data is written before connection closes.
pub struct Connection {
    /// Buffered writer - DROP FIRST: flushes before stream closes
    writer: BufWriter<TcpStream>,
    /// TCP stream - DROP SECOND: closes after flush complete
    stream: TcpStream,
}

// --- FIX 9: Standard Error Pattern with thiserror ---
// Grit: Use thiserror for consistent, maintainable error types

use thiserror::Error;

#[derive(Debug, Error)]
pub enum ServiceError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("parse error: {0}")]
    Parse(#[from] std::num::ParseIntError),

    #[error("not found: {id}")]
    NotFound { id: String },

    #[error("validation failed: {reason}")]
    Validation { reason: String },
}

// thiserror automatically implements:
// - std::fmt::Display
// - std::error::Error
// - From<T> for #[from] variants
// No boilerplate!

fn example_error_usage() -> Result<(), ServiceError> {
    let _value: i32 = "42".parse()?; // Auto-converts ParseIntError
    Ok(())
}

// --- FIX 10: Iterator Chains Instead of Imperative Loops ---
// Grit: Use functional iteration for transformations

struct DataItem {
    name: String,
}

impl DataItem {
    fn is_valid(&self) -> bool {
        !self.name.is_empty()
    }
}

fn process_items_grit(items: &[DataItem]) -> Vec<String> {
    // Grit: Iterator chain - declarative, composable, no mutable state
    items
        .iter()
        .filter(|item| item.is_valid())
        .map(|item| item.name.clone())
        .collect()
}

fn process_each(items: &[DataItem]) {
    // Grit: Direct iteration, not index-based
    for item in items {
        process_item(item);
    }
}

fn process_with_index(items: &[DataItem]) {
    // Grit: Use enumerate() when index is needed
    for (idx, item) in items.iter().enumerate() {
        println!("Item {}: {}", idx, item.name);
    }
}

fn find_and_transform(items: &[DataItem]) -> Option<String> {
    // Grit: Use find_map for search-and-transform
    items
        .iter()
        .find(|item| item.is_valid())
        .map(|item| item.name.to_uppercase())
}

fn process_item(_item: &DataItem) {}

// --- FIX 11: Single Async Runtime (tokio) ---
// Grit: Standardize on tokio for all async operations

use tokio::{fs, time};
use std::time::Duration;

async fn read_config_grit() -> Result<String, std::io::Error> {
    // Grit: Use tokio utilities consistently
    let contents = fs::read_to_string("config.toml").await?;
    Ok(contents)
}

async fn delayed_operation() {
    // Grit: tokio::time, not async-std::task::sleep
    time::sleep(Duration::from_secs(1)).await;
    println!("Operation complete");
}

// --- FIX 12: #[non_exhaustive] on Public Enums ---
// Grit: Public enums that may gain variants must be non_exhaustive

/// Errors returned by the API.
///
/// Rule 11: `#[non_exhaustive]` allows adding variants in minor releases.
#[non_exhaustive]
pub enum ApiError {
    NotFound,
    Unauthorized,
    // New variants can be added without breaking downstream code
}

// --- FIX 13: #[must_use] on Pure Functions ---
// Grit: Pure functions annotated so discarding their result warns

/// Validates that the input is non-empty.
///
/// Rule 12: `#[must_use]` — discarding the result is likely a bug.
#[must_use]
pub fn validate_input(input: &str) -> bool {
    !input.is_empty()
}

fn caller_correct() {
    let input = "";
    if validate_input(input) { // Return value is used
        println!("Valid");
    }
}

// --- FIX 14: Arc + JoinSet for Shared State in Spawned Tasks ---
// Grit: Wrap non-Clone shared state in Arc for spawned async tasks
//
// When a type does not implement Clone and must be shared across
// spawned tasks (which require 'static futures), wrap it in Arc.
// Use a Semaphore to limit concurrency.

use std::sync::Arc;
use tokio::sync::Semaphore;
use tokio::task::JoinSet;

struct Repo; // Imagine this is not Clone (e.g., wraps a client + config)

impl Repo {
    async fn get(&self, _file: &str) -> Result<String, std::io::Error> {
        Ok(String::new())
    }
}

async fn download_files(repo: Repo, files: Vec<String>) -> Vec<String> {
    let concurrency = 4;
    let repo = Arc::new(repo);
    let semaphore = Arc::new(Semaphore::new(concurrency));
    let mut join_set = JoinSet::new();

    for file in files {
        let permit = Arc::clone(&semaphore)
            .acquire_owned()
            .await
            .unwrap(); // OK in application code (Rule 3 is for libraries)

        let task_repo = Arc::clone(&repo);
        join_set.spawn(async move {
            let result = task_repo.get(&file).await;
            drop(permit);
            (file, result)
        });
    }

    let mut results = Vec::new();
    while let Some(Ok((file, Ok(data)))) = join_set.join_next().await {
        results.push(format!("{file}: {}", data.len()));
    }
    results
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Grit: Clear tokio runtime entry point
    let config = read_config_grit().await?;
    println!("Config: {}", config);
    Ok(())
}
