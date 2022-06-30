# bincode-zig

A [Zig](https://ziglang.org) implementation of the [Bincode](https://github.com/bincode-org/bincode) binary format specification.

## Setup

In build.zig:

```zig
const std = @import("std");

const bincode_pkg: std.build.Pkg = .{
    .name = "bincode",
    .path = .{ .path = "bincode-zig/bincode.zig" },
};

// Assume 'step' is a *std.build.LibExeObjStep.
step.addPackage(bincode_pkg);
```

## Specification

The endianness of serialized values by default is little-endian. This may be configured.

Boolean types are encoded as 1 byte. 0 for false, 1 for true.

All basic numeric types will be encoded as either variable-length integers or fixed-length integers depending on the configured integer encoding.

The numeric type `usize` is encoded/decoded as a `u64`. The numeric type `isize` is encoded/decoded as a `i64`.

All floating point types will take up either exactly 4 bytes (to represent a `f32`) or 8 bytes (to represent a `f64`).

All members that are part of a tuple or struct are encoded as-is in their specified order.

Enums are encoded by their discriminant first, followed by their payload.

Slices and vectors are encoded by their length first, followed by their elements.

Fixed-length arrays are not encoded by their lengths first. This may be configured.

Encoding an unsigned variable-length integer u (of any type excepting `u8`) works as follows:

1. If `u < 251`, encode it as a single byte with that value.
2. If `251 <= u < 2**16`, encode it as a literal byte 251, followed by a `u16` with value u.
3. If `2**16 <= u < 2**32`, encode it as a literal byte 252, followed by a `u32` with value u.
4. If `2**32 <= u < 2**64`, encode it as a literal byte 253, followed by a `u64` with value u.
5. If `2**64 <= u < 2**128`, encode it as a literal byte 254, followed by a `u128` with value u.
6. If `2**128 <= u < 2**256`, encode it as a literal byte 255, followed by a `u256` with value u.

Encoded a signed variable-length integer works by first converting the integer to an unsigned integer using the zigzag algorithm, and then encoding the unsigned integer as an unsigned variable-length integer.

The zigzag algorithm is defined as follows:

```zig
fn zigzag(v: Signed) Unsigned {
    return if (v < 0) (~@bitCast(Unsigned, v) * 2 + 1) else (@intCast(Unsigned, v) * 2);
}
```

Fixed-length integers are encoded directly. When configured to encode/decode integers as fixed-length integers, enum discriminants are encoded as `u32`, and lengths are encoded as the numeric type `usize`. 


