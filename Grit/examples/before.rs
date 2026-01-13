// before.rs - Common AI mistakes in Rust
// These patterns compile but contain subtle bugs or anti-patterns that AI frequently generates.

use std::any::Any;
use std::collections::HashMap;

// --- MISTAKE 1: Elided Lifetimes ---
// AI often omits lifetimes, making borrow relationships unclear

// In an impl block, AI generates:
// pub fn get_name(&self) -> &str {
//     &self.name // Which lifetime? AI and readers can't tell
// }

pub fn parse(input: &str) -> Option<&str> {
    // Does the output borrow from input? Unclear!
    input.split(':').next()
}

// --- MISTAKE 2: Implicit Deref Coercion ---
// AI relies on implicit conversions that hide what's happening

fn process_str(s: &str) {
    println!("{}", s);
}

fn use_string() {
    let string = String::from("hello");
    process_str(&string); // Implicit Deref - what type is being passed?
}

// --- MISTAKE 3: Unwrap/Expect in Library Code ---
// AI frequently generates panicking code

fn get_user(users: &HashMap<String, User>, id: &str) -> &User {
    users.get(id).unwrap() // PANIC if not found!
}

fn parse_number(input: &str) -> i32 {
    input.parse().expect("invalid number") // PANIC on bad input!
}

fn first_item<T>(vec: &Vec<T>) -> &T {
    &vec[0] // PANIC if empty!
}

// --- MISTAKE 4: Type Erasure with Any ---
// AI uses Any when it doesn't know the concrete type

fn store_anything(item: Box<dyn Any>) {
    // Can't do anything useful without downcasting
}

fn process_dynamic(handler: Box<dyn Fn()>) {
    // Dynamic dispatch when static would work
    handler();
}

// --- MISTAKE 5: Unsafe Mixed with Safe Code ---
// AI generates unsafe blocks inline without safety documentation

fn transmute_data(data: &[u8]) -> u32 {
    unsafe {
        // No safety comment! What are the requirements?
        std::ptr::read(data.as_ptr() as *const u32)
    }
}

// --- MISTAKE 6: References in Async ---
// AI generates async functions with reference parameters

// In an impl block, AI generates:
// async fn fetch_user_by_ref(&self, id: &str) -> User {
//     // Lifetime complexity - self and id must live for entire future
//     todo!()
// }
//
// async fn process_data<'a>(&'a self) -> &'a str {
//     // Complex lifetime bounds that confuse AI
//     todo!()
// }

// --- MISTAKE 7: Wildcard Match Arms ---
// AI uses _ to "handle" cases it doesn't understand

#[derive(Debug)]
enum Status {
    Active,
    Pending,
    Cancelled,
    Expired,
}

fn handle_status(status: Status) {
    match status {
        Status::Active => println!("Active!"),
        _ => {} // What statuses are being ignored? Why?
    }
}

// --- MISTAKE 8: Implicit Drop Order ---
// AI doesn't document destruction order dependencies

struct Connection {
    writer: BufWriter<TcpStream>,
    stream: TcpStream, // Drop order matters but isn't documented!
}

// --- MISTAKE 9: Ad-hoc Error Types ---
// AI creates boilerplate error types without thiserror

#[derive(Debug)]
enum ServiceError {
    Io(std::io::Error),
    Parse(std::num::ParseIntError),
}

impl std::fmt::Display for ServiceError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ServiceError::Io(e) => write!(f, "IO error: {}", e),
            ServiceError::Parse(e) => write!(f, "Parse error: {}", e),
        }
    }
}

impl std::error::Error for ServiceError {} // Boilerplate!

impl From<std::io::Error> for ServiceError {
    fn from(e: std::io::Error) -> Self {
        ServiceError::Io(e)
    }
}

// --- MISTAKE 10: Imperative Loops for Transformations ---
// AI writes verbose imperative code instead of iterators

fn process_items(items: &[Item]) -> Vec<String> {
    let mut results = Vec::new();
    for item in items {
        if item.is_valid() {
            results.push(item.name.clone());
        }
    }
    results
}

fn find_by_index(items: &[Item]) {
    for i in 0..items.len() {
        process(&items[i]); // Index-based iteration
    }
}

// --- MISTAKE 11: Mixed Async Runtimes ---
// AI mixes utilities from different async ecosystems

// use async_std::fs;  // One runtime
// use tokio::time;    // Different runtime!
// This causes runtime panics or subtle bugs

// Helper types for compilation
struct Item {
    name: String,
}

impl Item {
    fn is_valid(&self) -> bool {
        !self.name.is_empty()
    }
}

fn process(_item: &Item) {}

// Helper types for compilation
struct User {
    name: String,
}

use std::io::BufWriter;
use std::net::TcpStream;

impl User {
    fn get_name(&self) -> &str {
        &self.name
    }
}
