// after.zig - Gizmo-compliant versions
// These patterns follow Gizmo rules and eliminate the subtle bugs.

const std = @import("std");

// --- FIX 1: Documented Allocator Ownership ---
// Gizmo: Document who owns allocated memory

/// Creates a buffer of 1024 bytes.
///
/// OWNERSHIP: Caller owns returned memory. Must free with same allocator.
/// BORROW: allocator - callee does not take ownership of allocator.
///
/// Example:
/// ```zig
/// const buf = try createBuffer(allocator);
/// defer allocator.free(buf);
/// ```
pub fn createBuffer(allocator: std.mem.Allocator) ![]u8 {
    return allocator.alloc(u8, 1024);
}

/// Processes input data and returns transformed result.
///
/// OWNERSHIP: Caller owns returned memory. Must free with same allocator.
/// On error, no memory is leaked (errdefer handles cleanup).
pub fn processData(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    const buffer = try allocator.alloc(u8, input.len * 2);
    errdefer allocator.free(buffer); // CLEANUP: Free buffer if transform fails

    const result = try transform(buffer, input);
    return result;
}

fn transform(dest: []u8, src: []const u8) ![]u8 {
    _ = dest;
    _ = src;
    return error.NotImplemented;
}

// --- FIX 2: Explicit Error Handling ---
// Gizmo: Document fallback behavior in catch blocks

pub fn parseConfig(data: []const u8) i32 {
    return std.fmt.parseInt(i32, data, 10) catch |err| {
        // FALLBACK: Default to 0 for invalid config values
        // This is expected for optional numeric config fields
        std.log.debug("config parse failed: {}, using default 0", .{err});
        return 0;
    };
}

/// Reads file size, returning 0 if file cannot be accessed.
///
/// FALLBACK: Returns 0 on any file access error. Check file existence
/// separately if you need to distinguish "file not found" from "size is 0".
pub fn readFileSize(path: []const u8) u64 {
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        // FALLBACK: Can't open file - treat as empty
        std.log.debug("cannot open {s}: {}", .{ path, err });
        return 0;
    };
    defer file.close();

    const stat = file.stat() catch |err| {
        // FALLBACK: Can't stat file - treat as empty
        std.log.debug("cannot stat {s}: {}", .{ path, err });
        return 0;
    };
    return stat.size;
}

// --- FIX 3: Exhaustive Error Switches ---
// Gizmo: Handle all error variants explicitly in switch statements

pub fn handleOpenError(err: std.fs.File.OpenError) void {
    switch (err) {
        error.FileNotFound => std.debug.print("file not found\n", .{}),
        error.AccessDenied => std.debug.print("access denied\n", .{}),
        error.IsDir => std.debug.print("path is a directory\n", .{}),
        error.NoSpaceLeft => std.debug.print("no space left on device\n", .{}),
        error.FileTooBig => std.debug.print("file too large\n", .{}),
        error.InvalidUtf8 => std.debug.print("invalid UTF-8 in path\n", .{}),
        error.BadPathName => std.debug.print("invalid path name\n", .{}),
        error.SymLinkLoop => std.debug.print("too many symbolic links\n", .{}),
        error.NameTooLong => std.debug.print("path name too long\n", .{}),
        error.NotDir => std.debug.print("component is not a directory\n", .{}),
        error.SystemResources => std.debug.print("system resources exhausted\n", .{}),
        error.WouldBlock => std.debug.print("operation would block\n", .{}),
        error.FileBusy => std.debug.print("file is busy\n", .{}),
        error.DeviceBusy => std.debug.print("device is busy\n", .{}),
        error.NoDevice => std.debug.print("device not found\n", .{}),
        error.NetworkNotFound => std.debug.print("network path not found\n", .{}),
        error.Unexpected => std.debug.print("unexpected OS error\n", .{}),
        // EXHAUSTIVE: All error variants handled
        else => std.debug.print("unhandled file error: {}\n", .{err}),
    }
}

const ProcessError = error{
    InvalidInput,
    ComputationFailed,
};

/// Processes a result, returning -1 on error.
///
/// FALLBACK: Returns -1 for any error. Caller should check return value
/// and handle error case appropriately.
pub fn processResult(result: ProcessError!i32) i32 {
    return result catch |err| {
        // FALLBACK: Return sentinel value for error
        std.log.warn("process failed: {}, returning -1", .{err});
        return -1;
    };
}

// --- FIX 4: Explicit Optional Handling ---
// Gizmo: Break optional chains into documented steps

const Profile = struct {
    display_name: ?[]const u8,
};

const User = struct {
    profile: ?Profile,
    username: []const u8,
};

/// Gets the user's display name with fallback chain.
///
/// FALLBACK: Returns "anonymous" if user is null.
/// FALLBACK: Returns username if profile is null.
/// FALLBACK: Returns username if display_name is null.
pub fn getUserDisplayName(user: ?User) []const u8 {
    // NULL: No user provided - return anonymous
    const u = user orelse return "anonymous";

    // NULL: User has no profile - fall back to username
    const profile = u.profile orelse return u.username;

    // NULL: Profile has no display name - fall back to username
    return profile.display_name orelse u.username;
}

// --- FIX 5: Documented anytype Constraints ---
// Gizmo: Document required interface for anytype parameters

/// Serializes a value to a writer.
///
/// TYPE CONSTRAINT for `writer`:
/// - Must have `fn writeAll(self, []const u8) anyerror!void`
///
/// TYPE CONSTRAINT for `value`:
/// - Must have `fn toBytes(self) []const u8`
pub fn serialize(writer: anytype, value: anytype) !void {
    try writer.writeAll(value.toBytes());
}

/// Processes an item by calling its process method.
///
/// TYPE CONSTRAINT for `item`:
/// - Must have `fn process(self: @TypeOf(item)) void`
pub fn process(item: anytype) void {
    item.process();
}

// --- FIX 6: Limited comptime Usage ---
// Gizmo: comptime only for type construction and static assertions

/// Creates a fixed-size matrix type.
///
/// COMPTIME: rows and cols must be known at compile time.
pub fn Matrix(comptime rows: usize, comptime cols: usize) type {
    // STATIC ASSERT: Validate dimensions at compile time
    comptime {
        std.debug.assert(rows > 0);
        std.debug.assert(cols > 0);
    }

    return struct {
        const Self = @This();

        data: [rows][cols]f64,

        pub fn init() Self {
            return .{ .data = std.mem.zeroes([rows][cols]f64) };
        }

        pub fn identity() Self {
            // STATIC ASSERT: Identity matrix requires square dimensions
            comptime std.debug.assert(rows == cols);

            var result = init();
            inline for (0..rows) |i| {
                result.data[i][i] = 1.0;
            }
            return result;
        }
    };
}

// Runtime computation instead of complex comptime
pub fn computeLookupTable(allocator: std.mem.Allocator, size: usize) ![]u32 {
    // OWNERSHIP: Caller owns returned memory
    const table = try allocator.alloc(u32, size);
    errdefer allocator.free(table);

    for (table, 0..) |*entry, i| {
        // Runtime computation - debuggable, doesn't slow compilation
        var val: u32 = @intCast(i);
        var j: usize = 0;
        while (j < 1000) : (j += 1) {
            val = (val *% 1103515245 +% 12345) % (1 << 31);
        }
        entry.* = val;
    }
    return table;
}

// --- FIX 7: Documented Cleanup Order ---
// Gizmo: One defer per resource with order comments

/// Processes a file with multiple resources.
///
/// CLEANUP ORDER (LIFO - last defer runs first):
/// 1. header buffer freed
/// 2. main buffer freed
/// 3. file closed
pub fn processFile(allocator: std.mem.Allocator, path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close(); // CLEANUP[3]: File closed last

    const buffer = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer); // CLEANUP[2]: Main buffer freed second

    const header = try allocator.alloc(u8, 64);
    defer allocator.free(header); // CLEANUP[1]: Header freed first

    try doWork(file, buffer, header);
}

fn doWork(file: std.fs.File, buffer: []u8, header: []u8) !void {
    _ = file;
    _ = buffer;
    _ = header;
}

// --- FIX 8: Slices Instead of Pointer Arithmetic ---
// Gizmo: Use slices for bounds safety

pub fn sumArray(items: []const i32) i32 {
    var sum: i32 = 0;
    for (items) |item| {
        sum += item; // Bounds-checked iteration
    }
    return sum;
}

pub fn findInBuffer(buffer: []const u8, needle: u8) ?usize {
    for (buffer, 0..) |byte, i| {
        if (byte == needle) return i;
    }
    return null;
}

// --- FIX 9: Proper unreachable Usage ---
// Gizmo: unreachable only for provably impossible states

const StatusError = error{InvalidStatusCode};

/// Returns the name for a status code.
///
/// Returns error.InvalidStatusCode for unknown codes instead of crashing.
pub fn getStatusName(code: u8) StatusError![]const u8 {
    return switch (code) {
        0 => "idle",
        1 => "running",
        2 => "complete",
        else => error.InvalidStatusCode, // EXPLICIT: Unknown codes are errors
    };
}

const DivisionError = error{DivisionByZero};

/// Divides two numbers safely.
///
/// Returns error.DivisionByZero if b is zero.
pub fn divideNumbers(a: i32, b: i32) DivisionError!i32 {
    if (b == 0) return error.DivisionByZero; // EXPLICIT: Handle zero case
    return @divTrunc(a, b);
}

// unreachable is OK here because the assertion proves impossibility:
pub fn divideNonZeroAsserted(a: i32, b: i32) i32 {
    std.debug.assert(b != 0); // Precondition: caller guarantees b != 0
    // UNREACHABLE: Assertion above proves b != 0
    return @divTrunc(a, b);
}

// --- FIX 10: Avoid Unnecessary Packed Structs ---
// Gizmo: Regular structs unless C interop required

const Config = struct {
    version: u16,
    flags: u8,
    mode: u8,
    // Regular struct - portable, predictable alignment
};

const Message = struct {
    id: u32,
    timestamp: u64,
    // Regular struct - compiler optimizes layout
};

/// Network packet header for wire protocol.
///
/// C INTEROP: Must match network byte layout exactly.
/// Used with sendto() and recvfrom() syscalls.
const PacketHeader = packed struct {
    version: u4,
    header_len: u4,
    type_of_service: u8,
    total_length: u16,
    // Packed required for network protocol compliance
};

// --- FIX 11: errdefer for Multiple Allocations ---
// Gizmo: Use errdefer to prevent leaks

/// Creates a set of resources.
///
/// OWNERSHIP: Caller owns all buffers. Free with deinit().
pub fn createResources(allocator: std.mem.Allocator) !Resources {
    const buffer1 = try allocator.alloc(u8, 1024);
    errdefer allocator.free(buffer1); // CLEANUP: Free if buffer2 alloc fails

    const buffer2 = try allocator.alloc(u8, 2048);
    errdefer allocator.free(buffer2); // CLEANUP: Free if buffer3 alloc fails

    const buffer3 = try allocator.alloc(u8, 4096);
    // No errdefer needed - if we reach here, all allocations succeeded

    return Resources{
        .buffer1 = buffer1,
        .buffer2 = buffer2,
        .buffer3 = buffer3,
        .allocator = allocator,
    };
}

const Resources = struct {
    buffer1: []u8,
    buffer2: []u8,
    buffer3: []u8,
    allocator: std.mem.Allocator,

    /// Frees all resources.
    pub fn deinit(self: *Resources) void {
        self.allocator.free(self.buffer3); // CLEANUP[1]
        self.allocator.free(self.buffer2); // CLEANUP[2]
        self.allocator.free(self.buffer1); // CLEANUP[3]
    }
};

// --- FIX 12: Proper Sentinel-Terminated Strings ---
// Gizmo: Use sentinel-terminated slices for C interop

/// Calls a C function with a null-terminated path.
///
/// C INTEROP: Converts Zig slice to null-terminated string for C API.
pub fn callCFunction(allocator: std.mem.Allocator, path: []const u8) !void {
    // Create null-terminated copy for C
    const c_path = try allocator.dupeZ(u8, path);
    defer allocator.free(c_path);

    _ = std.c.open(c_path.ptr, 0);
}

/// Creates a null-terminated C string from a Zig slice.
///
/// OWNERSHIP: Caller owns returned memory. Must free with allocator.
/// C INTEROP: Result is null-terminated, safe to pass to C functions.
pub fn createCString(allocator: std.mem.Allocator, s: []const u8) ![:0]u8 {
    // dupeZ creates null-terminated copy
    return allocator.dupeZ(u8, s);
}
