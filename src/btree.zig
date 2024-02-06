const std = @import("std");

const c = @cImport({
    @cInclude("btree.h");
});

pub fn Btree(comptime T: type, comptime Context: type) type {
    return struct {
        const Self = @This();

        handle: *c.struct_btree = undefined,

        pub fn init(max_items: usize, comptime compare: fn (a: *T, b: *T, context: ?*Context) c_int, context: ?*Context) Self {
            const cb = struct {
                fn comp(a: ?*const anyopaque, b: ?*const anyopaque, ctx: ?*anyopaque) callconv(.C) c_int {
                    return compare(@ptrCast(@alignCast(@constCast(a))), @ptrCast(@alignCast(@constCast(b))), @ptrCast(@alignCast(ctx)));
                }
            };

            return .{
                .handle = c.btree_new(@sizeOf(T), max_items, cb.comp, context).?,
            };
        }

        pub fn deinit(self: *Self) void {
            c.btree_free(self.handle);
        }

        pub fn get(self: *Self, key: *const T) ?*T {
            if (c.btree_get(self.handle, key)) |element| {
                return @ptrCast(@alignCast(@constCast(element)));
            }

            return null;
        }

        pub fn set(self: *Self, item: *const T) ?*T {
            if (c.btree_set(self.handle, item)) |element| {
                return @ptrCast(@alignCast(@constCast(element)));
            }

            return null;
        }

        pub fn delete(self: *Self, key: *const T) ?*T {
            if (c.btree_delete(self.handle, key)) |element| {
                return @ptrCast(@alignCast(@constCast(element)));
            }

            return null;
        }

        pub fn clone(self: *Self) ?Self {
            if (c.btree_clone(self.handle)) |tree| {
                return .{
                    .handle = tree,
                };
            }

            return null;
        }

        pub fn count(self: *Self) usize {
            return c.btree_count(self.handle);
        }

        pub fn ascend(self: *Self, comptime ContextType: type, context: ?*ContextType, pivot: ?*const anyopaque, comptime iter: fn (a: *T, context: ?*ContextType) bool) bool {
            const cb = struct {
                fn iterator(a: ?*const anyopaque, ctx: ?*anyopaque) callconv(.C) bool {
                    return iter(@ptrCast(@alignCast(@constCast(a))), @ptrCast(@alignCast(ctx)));
                }
            };

            return c.btree_ascend(self.handle, pivot, cb.iterator, context);
        }

        pub fn descent(self: *Self, comptime ContextType: type, context: ?*ContextType, pivot: ?*const anyopaque, comptime iter: fn (a: *T, context: ?*ContextType) bool) bool {
            const cb = struct {
                fn iterator(a: ?*const anyopaque, ctx: ?*anyopaque) callconv(.C) bool {
                    return iter(@ptrCast(@alignCast(@constCast(a))), @ptrCast(@alignCast(ctx)));
                }
            };

            return c.btree_descend(self.handle, pivot, cb.iterator, context);
        }

        pub fn popMin(self: *Self) ?*T {
            if (c.btree_pop_min(self.handle)) |element| {
                return @ptrCast(@alignCast(@constCast(element)));
            }

            return null;
        }

        pub fn popMax(self: *Self) ?*T {
            if (c.btree_pop_max(self.handle)) |element| {
                return @ptrCast(@alignCast(@constCast(element)));
            }

            return null;
        }

        pub fn min(self: *Self) ?*T {
            if (c.btree_min(self.handle)) |element| {
                return @ptrCast(@alignCast(@constCast(element)));
            }

            return null;
        }

        pub fn max(self: *Self) ?*T {
            if (c.btree_max(self.handle)) |element| {
                return @ptrCast(@alignCast(@constCast(element)));
            }

            return null;
        }

        pub fn load(self: *Self, item: *const T) ?void {
            if (c.btree_load(self.handle, item)) |_| {}

            return null;
        }

        pub fn oom(self: *Self) bool {
            return c.btree_oom(self.handle);
        }

        pub fn clear(self: *Self) void {
            c.btree_clear(self.handle);
        }

        pub fn height(self: *Self) usize {
            return c.btree_height(self.handle);
        }
    };
}

pub fn Iterator(comptime T: type) type {
    return struct {
        const Self = @This();

        handle: *c.struct_btree_iter = undefined,

        pub fn init(comptime Type: type, btree: *Type) Self {
            return .{
                .handle = c.btree_iter_new(btree.handle).?,
            };
        }

        pub fn deinit(self: *Self) void {
            c.btree_iter_free(self.handle);
        }

        pub fn first(self: *Self) bool {
            return c.btree_iter_first(self.handle);
        }

        pub fn last(self: *Self) bool {
            return c.btree_iter_last(self.handle);
        }

        pub fn next(self: *Self) bool {
            return c.btree_iter_next(self.handle);
        }

        pub fn prev(self: *Self) bool {
            return c.btree_iter_prev(self.handle);
        }

        pub fn seek(self: *Self, key: *const T) bool {
            return c.btree_iter_seek(self.handle, key);
        }

        pub fn item(self: *Self) ?*T {
            return @ptrCast(@alignCast(@constCast(c.btree_iter_item(self.handle))));
        }
    };
}
