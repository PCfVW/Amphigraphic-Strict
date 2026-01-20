// before.zig - Common AI mistakes in Zig
// These patterns compile but contain subtle bugs or anti-patterns that AI frequently generates.

const std = @import("std");

// --- MISTAKE 1: Undocumented Allocator Ownership ---
// AI often returns allocated memory without documenting who frees it

pub fn createBuffer(allocator: std.mem.Allocator) ![]u8 {
    // Who owns this memory? Caller? Does this function ever free it on error?
    return allocator.alloc(u8, 1024);
}

pub fn processData(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    const buffer = try allocator.alloc(u8, input.len * 2);
    // If next line fails, buffer leaks!
    const result = try transform(buffer, input);
    return result;
}

fn transform(dest: []u8, src: []const u8) ![]u8 {
    _ = dest;
    _ = src;
    return error.NotImplemented;
}

// --- MISTAKE 2: Silent Error Discarding ---
// AI uses catch with silent fallbacks

pub fn parseConfig(data: []const u8) i32 {
    // Error silently swallowed - what went wrong?
    return std.fmt.parseInt(i32, data, 10) catch 0;
}

pub fn readFileSize(path: []const u8) u64 {
    const file = std.fs.cwd().openFile(path, .{}) catch return 0; // Silent failure
    defer file.close();
    const stat = file.stat() catch return 0; // Another silent failure
    return stat.size;
}

// --- MISTAKE 3: Catch-All Error Switches ---
// AI uses else to ignore error variants in switches

pub fn handleOpenError(err: std.fs.File.OpenError) void {
    switch (err) {
        error.FileNotFound => std.debug.print("not found\n", .{}),
        else => {}, // What about AccessDenied? IsDir? Many errors silently ignored!
    }
}

pub fn processResult(result: anyerror!i32) i32 {
    return result catch |err| {
        _ = err; // AI captures error but does nothing
        return -1;
    };
}

// --- MISTAKE 4: Chained Optional Access ---
// AI chains .? operators making null paths unclear

const Profile = struct {
    display_name: ?[]const u8,
};

const User = struct {
    profile: ?Profile,
};

pub fn getUserDisplayName(user: ?User) ?[]const u8 {
    // Which null case triggered the failure? User? Profile? Name?
    return user.?.profile.?.display_name;
}

// --- MISTAKE 5: Undocumented anytype Constraints ---
// AI uses anytype without documenting requirements

pub fn serialize(writer: anytype, value: anytype) !void {
    // What methods must writer have? What about value?
    try writer.writeAll(value.toBytes());
}

pub fn process(item: anytype) void {
    // AI assumes .process() exists but doesn't document it
    item.process();
}

// --- MISTAKE 6: Complex comptime Logic ---
// AI generates complex compile-time computations

pub fn computeLookupTable(comptime size: usize) [size]u32 {
    comptime {
        var table: [size]u32 = undefined;
        for (0..size) |i| {
            // Complex comptime computation - hard to debug, slow compilation
            var val: u32 = @intCast(i);
            var j: usize = 0;
            while (j < 1000) : (j += 1) {
                val = (val *% 1103515245 +% 12345) % (1 << 31);
            }
            table[i] = val;
        }
        return table;
    }
}

// --- MISTAKE 7: Multiple Defers Without Order Documentation ---
// AI adds defers without explaining cleanup order

pub fn processFile(allocator: std.mem.Allocator, path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer);

    const header = try allocator.alloc(u8, 64);
    defer allocator.free(header);

    // Which defer runs first? Does order matter here?
    // If file.close() fails, are buffers still freed?
    try doWork(file, buffer, header);
}

fn doWork(file: std.fs.File, buffer: []u8, header: []u8) !void {
    _ = file;
    _ = buffer;
    _ = header;
}

// --- MISTAKE 8: Pointer Arithmetic Instead of Slices ---
// AI generates C-style pointer code

pub fn sumArrayPointer(ptr: [*]const i32, len: usize) i32 {
    var sum: i32 = 0;
    var i: usize = 0;
    while (i < len) : (i += 1) {
        sum += ptr[i]; // No bounds checking - can read out of bounds
    }
    return sum;
}

pub fn findInBuffer(ptr: [*]const u8, len: usize, needle: u8) ?usize {
    var i: usize = 0;
    while (i < len) : (i += 1) {
        if (ptr[i] == needle) return i;
    }
    return null;
}

// --- MISTAKE 9: unreachable Misuse ---
// AI uses unreachable to hide unhandled cases

pub fn getStatusName(code: u8) []const u8 {
    return switch (code) {
        0 => "idle",
        1 => "running",
        2 => "complete",
        else => unreachable, // What if code is 3? Runtime crash!
    };
}

pub fn divideNumbers(a: i32, b: i32) i32 {
    if (b == 0) unreachable; // This doesn't prevent division by zero!
    return @divTrunc(a, b);
}

// --- MISTAKE 10: Unnecessary Packed Structs ---
// AI uses packed when not needed

const Config = packed struct {
    version: u16,
    flags: u8,
    mode: u8,
    // Packed without reason - causes alignment issues, slower access
};

const Message = packed struct {
    id: u32,
    timestamp: u64,
    // No C interop, no network protocol - why packed?
};

// --- MISTAKE 11: Missing errdefer ---
// AI allocates multiple resources without errdefer

pub fn createResources(allocator: std.mem.Allocator) !Resources {
    const buffer1 = try allocator.alloc(u8, 1024);
    const buffer2 = try allocator.alloc(u8, 2048); // If this fails, buffer1 leaks!
    const buffer3 = try allocator.alloc(u8, 4096); // If this fails, buffer1 and buffer2 leak!

    return Resources{
        .buffer1 = buffer1,
        .buffer2 = buffer2,
        .buffer3 = buffer3,
    };
}

const Resources = struct {
    buffer1: []u8,
    buffer2: []u8,
    buffer3: []u8,
};

// --- MISTAKE 12: Ignoring Sentinel Values ---
// AI mishandles sentinel-terminated slices for C interop

pub fn callCFunction(path: []const u8) void {
    // AI passes Zig slice to C function expecting null-terminated string
    // This is wrong - C will read past the buffer!
    _ = std.c.open(@ptrCast(path.ptr), 0);
}

pub fn createCString(allocator: std.mem.Allocator, s: []const u8) ![]u8 {
    // AI forgets to null-terminate for C interop
    const result = try allocator.alloc(u8, s.len);
    @memcpy(result, s);
    return result; // Not null-terminated!
}
