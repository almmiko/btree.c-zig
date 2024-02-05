const std = @import("std");

const Btree = @import("btree.zig").Btree;

const User = struct {
    name: []const u8,
};

const Context = struct {
    key: []const u8,
};

const Wrapper = struct {
    pub fn compare(a: *User, b: *User, a1: ?*void) c_int {
        _ = a1;
        std.debug.print("call compare fn\n", .{});
        std.debug.print("a: {s}\n", .{a.name});
        std.debug.print("b: {s}\n", .{b.name});
        // std.debug.print("context: {s}\n", .{context.key});
        return 1;
    }

    pub fn iter(a: *User, ctx: ?*void) bool {
        _ = ctx;
        std.debug.print("iter: {s}\n", .{a.name});
        return true;
    }
};

pub fn main() !void {
    // var context = Context{ .key = "key" };

    var btree = Btree(User, void).init(0, Wrapper.compare, null);
    defer btree.deinit();

    const user1 = User{ .name = "user1" };
    const user2 = User{ .name = "user2" };

    btree.set(&user1);
    btree.set(&user2);

    const count = btree.count();

    std.debug.print("count: {d}\n", .{count});

    _ = btree.ascend(null, void, Wrapper.iter, null);
}
