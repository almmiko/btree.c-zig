const std = @import("std");

const btree = @cImport({
    @cInclude("btree.h");
});

pub fn Btree(comptime T: type, comptime Context: type) type {
    return struct {
        const Self = @This();

        handle: *btree.struct_btree = undefined,

        pub fn init(max_items: usize, compare: fn (a: *T, b: *T, context: ?*Context) c_int, context: ?*Context) Self {
            const Wrapper = struct {
                fn comp(a: ?*const anyopaque, b: ?*const anyopaque, udata: ?*anyopaque) callconv(.C) c_int {
                    return compare(@ptrCast(@alignCast(@constCast(a))), @ptrCast(@alignCast(@constCast(b))), @ptrCast(@alignCast(udata)));
                }
            };

            return .{
                .handle = btree.btree_new(@sizeOf(T), max_items, Wrapper.comp, context).?,
            };
        }

        pub fn set(self: *Self, item: *const T) void {
            _ = btree.btree_set(self.handle, item);
        }

        pub fn count(self: *Self) usize {
            return btree.btree_count(self.handle);
        }

        pub fn deinit(self: *Self) void {
            btree.btree_free(self.handle);
        }
    };
}
