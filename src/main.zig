const std = @import("std");

const Btree = @import("btree.zig").Btree;

const c = @cImport({
    @cInclude("string.h");
});

const User = struct {
    name: []const u8,
};

const Context = struct {
    key: []const u8,
};

const Wrapper = struct {
    pub fn compare(a: *User, b: *User, ctx: ?*void) c_int {
        _ = ctx;
        std.debug.print("call compare fn\n", .{});
        std.debug.print("a: {s}\n", .{a.name});
        std.debug.print("b: {s}\n", .{b.name});

        return c.strncmp(a.name.ptr, b.name.ptr, a.name.len);
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

    _ = btree.set(&user1);
    _ = btree.set(&user2);

    const count = btree.count();

    std.debug.print("count: {d}\n", .{count});

    _ = btree.ascend(void, null, null, Wrapper.iter);

    const user = btree.get(&user2);

    if (user) |usr| {
        std.debug.print("get method: user: {s}\n", .{usr.name});
    }
}
