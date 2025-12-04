# Dimensions.jl

This Julia package provides an interfacing for defining a type's "dimensions". E.g., a vector with 3 elements (which might be a position in 3D Cartesian space) would have 3 dimensions, the "x", "y", and "z" parts. Essentially, every scalar making up a type could be a dimension of that type.

(This is notably different use of the word "dimension" from Julia's "array dimensions". A 3-element vector is made of up 3 scalars and hence has three independent dimensions in the nomenclature here, even though the Vector type is a "1D array".)

The key functionality comes from the following functions:

* `numdims(x)` returns the number of dimensions of `x`
* `getdim(x, k)` returns dimension `k` of `x`
* `eachdim(x)` returns an iterator over the dimensions of `x`
* `dimstyle(t)` returns the dimension "style" of type `t`

By default, this works with `Real` numbers (1D), `Complex` numbers, (2D), enums (1D), and `Vector`s of `Real` elements. It also works for `SVectors` if you have StaticArrays imported.

To add "dimensional" behavior to a custom type, just add methods for those functions for your type. And in fact, most types can be handled simply by adding a method to `dimstyle`. Here's an example:

```
struct Position
    x::Float64
    y::Float64
    z::Float64
end

import Dimensions
Dimensions.dimstyle(::Type{Position}) = Dimensions.ScalarDimensionStyle()
```

The remaining functions are already implemented for that "style"; the dimensions will be taken as the combination of the dimensions of the dimensions of the fields. Here, `numdims(x)` will clearly be 3, `getdim(x, 2)` will return the `y` field, and `eachdim(x)` will return an iterator over `x`, then `y`, then `z`.

This is useful for anything that needs to break a type all the way down to its fundamental scalars. For instance, when plotting a vector of `Position` over time, a plotting package could first make a line for each position's dimension 1, then a line for each position's dimension 2, and then for each position's dimension 3, giving three lines. More generally, it is a way of serializing the data to scalars.
