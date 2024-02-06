const std = @import("std");

const btree = @cImport({
    @cInclude("btree.h");
});

pub fn Btree(comptime T: type, comptime Context: type) type {
    return struct {
        const Self = @This();

        handle: *btree.struct_btree = undefined,

        pub fn init(max_items: usize, comptime compare: fn (a: *T, b: *T, context: ?*Context) c_int, context: ?*Context) Self {
            const cb = struct {
                fn comp(a: ?*const anyopaque, b: ?*const anyopaque, ctx: ?*anyopaque) callconv(.C) c_int {
                    return compare(@ptrCast(@alignCast(@constCast(a))), @ptrCast(@alignCast(@constCast(b))), @ptrCast(@alignCast(ctx)));
                }
            };

            return .{
                .handle = btree.btree_new(@sizeOf(T), max_items, cb.comp, context).?,
            };
        }

        pub fn deinit(self: *Self) void {
            btree.btree_free(self.handle);
        }

        pub fn get(self: *Self, key: *const T) ?*T {
            if (btree.btree_get(self.handle, key)) |element| {
                return @ptrCast(@alignCast(@constCast(element)));
            }

            return null;
        }

        pub fn set(self: *Self, item: *const T) ?*T {
            if (btree.btree_set(self.handle, item)) |element| {
                return @ptrCast(@alignCast(@constCast(element)));
            }

            return null;
        }

        pub fn count(self: *Self) usize {
            return btree.btree_count(self.handle);
        }

        pub fn ascend(self: *Self, comptime ContextType: type, context: ?*ContextType, pivot: ?*const anyopaque, comptime iter: fn (a: *T, context: ?*ContextType) bool) bool {
            const cb = struct {
                fn iterator(a: ?*const anyopaque, ctx: ?*anyopaque) callconv(.C) bool {
                    return iter(@ptrCast(@alignCast(@constCast(a))), @ptrCast(@alignCast(ctx)));
                }
            };

            return btree.btree_ascend(self.handle, pivot, cb.iterator, context);
        }
    };
}
