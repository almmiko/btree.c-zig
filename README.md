# btree.c-zig

A wrapper around [btree.c](https://github.com/tidwall/btree.c) lib.

## Installation

This package uses Zig package manager.

To add btree.c-zig in the `build.zig.zon` file run:

```zig 
zig fetch --save https://github.com/almmiko/btree.c-zig/archive/<git-ref>.tar.gz
```

Or manually
```zig
.{
    .name = "project-zig",
    .version = "0.0.0",
    .dependencies = .{
        .@"btree-zig" = .{
            .url = "https://github.com/almmiko/btree.c-zig/archive/<git-ref>.tar.gz",
            .hash = "1220450bb9feb21c29018e21a8af457859eb2a4607a6017748bb618907b4cf18c67b",
        },
    },
    .paths = .{
        "",
    },
}
```

Add dependency in your `build.zig`

```zig
const btree_zig = b.dependency("btree-zig", .{
    .target = target,
    .optimize = optimize,
});

const btree_zig_module = btree_zig.module("btree_c_zig");

exe.root_module.addImport("btree-zig", btree_zig_module);
exe.linkLibrary(btree_zig.artifact("btree-zig"));
```

## Usage

Most of the APIs from btree.c are available, see [btree.h](https://github.com/tidwall/btree.c/blob/master/btree.h) for references.

### Example

```zig
  const cString = @cImport({
        @cInclude("string.h");
    });

    const User = struct {
        name: []const u8,
    };

    const cb = struct {
        pub fn compare(a: *User, b: *User, ctx: ?*void) c_int {
            return cString.strncmp(a.name.ptr, b.name.ptr, a.name.len);
        }
    };

    var btree = Btree(User, void).init(0, cb.compare, null);
    defer btree.deinit();

    const user1 = User{ .name = "user1" };
    const user2 = User{ .name = "user2" };

    _ = btree.set(&user1);
    _ = btree.set(&user2);

    _ = btree.get(&user1).?.*;

```

See [btree.zig ](https://github.com/almmiko/btree.c-zig/blob/main/src/btree.zig) for more examples.

## Tests

To test, run:
```zig
zig build test
```

## Credits

[btree.c](https://github.com/tidwall/btree.c) - B-tree implementation in C



