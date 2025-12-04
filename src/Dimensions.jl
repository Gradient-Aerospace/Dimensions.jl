module Dimensions

export dimstyle, numdims, getdim, eachdim

abstract type AbstractDimensionStyle end
struct UnknownDimensionStyle <: AbstractDimensionStyle end
struct ScalarDimensionStyle <: AbstractDimensionStyle end
struct ComplexDimensionStyle <: AbstractDimensionStyle end
struct RealVectorDimensionStyle <: AbstractDimensionStyle end
struct NdVectorDimensionStyle{N} <: AbstractDimensionStyle end # ConsistentVectorStyle?
# It seems like we could make a general vector dimension thing that acts like the struct thing.
struct StructDimensionStyle <: AbstractDimensionStyle end

"""
    dimstyle(x)

Returns the "dimension style" for `x`. The available dimension styles are:

* ScalarDimensionStyle: Always 1 dimensional
* ComplexDimensionStyle: Always 2 dimensional
* RealVectorDimensionStyle: The dimensions are the elements of the vector (all real)
* NdVectorDimensionStyle: All elements have the same dimensionality, so ... TODO
* StructDimensionStyle: TODO
"""
dimstyle(::Type{<: Any}) = UnknownDimensionStyle()
dimstyle(::Type{<: Real}) = ScalarDimensionStyle()
dimstyle(::Type{<: Complex}) = ComplexDimensionStyle()
dimstyle(::Type{<: Enum}) = ScalarDimensionStyle()
dimstyle(::Type{T}) where {T <: Vector{<: Real}} = RealVectorDimensionStyle()
dimstyle(::Type{Vector{T}}) where {T} = NdVectorDimensionStyle{numdims_for_type(T)}()

"""
    getdim(x, d)

Returns dimension `d` of `x` and throws an error if the given dimension is invalid.
"""
getdim(x, d) = getdim(dimstyle(typeof(x)), x, d)
getdim(::ScalarDimensionStyle, x, d) = d == 1 ? x : error("Dimension $d does not exist for a type with a `ScalarDimensionStyle``.")
getdim(::ComplexDimensionStyle, x, d) = d == 1 ? real(x) : (d == 2 ? imag(x) : error("Dimension $d does not exist for a type with a `ComplexDimensionStyle``."))
getdim(::RealVectorDimensionStyle, x, d) = x[d]
function getdim(::StructDimensionStyle, x::T, d) where {T}
    n_dims_so_far = 0
    for f in fieldnames(T)
        data = getfield(x, f)
        n_dims_this_field = numdims(data)
        # n_dims_this_field = numdims_for_type(fieldtype(T, f)) # If we want to require the type to tell us the dimensionality...
        if d <= n_dims_so_far + n_dims_this_field
            return getdim(data, d - n_dims_so_far)
        end
        n_dims_so_far += n_dims_this_field
    end
    error("Dimension $d does not exist for $T.")
end
getdim(::NdVectorDimensionStyle{N}, x, d) where {N} = getdim(x[cld(d, N)], mod1(d, N))

"""
    numdims_for_type(t)

Returns the number of dimensions for the given type. Note that this is not available for all
types. E.g., a Vector's dimensions are not available from its type.
"""
numdims_for_type(t) = numdims_for_type(dimstyle(t), t)
numdims_for_type(::ScalarDimensionStyle, t) = 1
numdims_for_type(::ComplexDimensionStyle, t) = 2
numdims_for_type(::StructDimensionStyle, t::Type{T}) where {T} = sum(numdims_for_type(ft) for ft in fieldtypes(T))
# Note that the following dimensions can't be known from their types: 
# RealVectorDimensionStyle, NdVectorDimensionStyle

"""
    numdims(x)

Returns the number of dimensions for `x`.
"""
numdims(x) = numdims(dimstyle(typeof(x)), x)
numdims(::ScalarDimensionStyle, x) = 1
numdims(::ComplexDimensionStyle, x) = 2
numdims(::RealVectorDimensionStyle, x) = length(x)
numdims(::StructDimensionStyle, x::T) where {T} = sum(numdims(getfield(x, f)) for f in fieldnames(T))
numdims(::NdVectorDimensionStyle{N}, x) where {N} = length(x) * N

"""
    eachdim(x)

Returns an iterator over the dimensions of `x`.
"""
eachdim(x) = eachdim(dimstyle(typeof(x)), x)
eachdim(::ScalarDimensionStyle, x) = (x,)
eachdim(::ComplexDimensionStyle, x) = (x.re, x.im)
eachdim(::RealVectorDimensionStyle, x) = x # already an iterator
eachdim(::AbstractDimensionStyle, x) = (getdim(x, d) for d in 1:numdims(x))

# TODO: Construct a thing from its dimensions (where that's possible).
# fielddims(type::Type) = (numdims_for_type(ft) for ft in fieldtypes(type))
# construct_from_dims(type, dims) = construct_from_dims(dimstyle(type), type, dims)
# construct_from_dims(::ScalarDimensionStyle, type::Type, dims) = type(only(dims))
# construct_from_dims(::ComplexDimensionStyle, type::Type, dims) = type(dims...)
# construct_from_dims(::RealVectorDimensionStyle, type::Type{T}, dims) where {T <: Vector} = dims
# function construct_from_dims(::StructDimensionStyle, type::Type{T}, dims) where {T}
#     field_dims = (numdims_for_type(ft) for ft in fieldtypes(type))
#     field_ends = cumsum(field_dims)
#     field_starts = field_ends .- field_dims .+ 1
#     return type(
#         (
#             construct_from_dims(ft, @view dims[fs : fe])
#             for (ft, fs, fe) in zip(fieldtypes(type), field_starts, field_ends)
#         )...
#     )
# end

# Note that we fundamentally don't know how to construct the struct if its fields don't have
# fixed dimension known from their types (e.g., if each field were a regular vector, we
# wouldn't know how long the first field's vector should be vs the second field's vector).
#
# The above could be faster with a generated function.

end # module Dimensions
