module DimensionsStaticArraysExt

using Dimensions: RealVectorDimensionStyle
import Dimensions
using StaticArrays: SVector

Dimensions.dimstyle(::Type{SVector{N, T}}) where {N, T <: Real} = RealVectorDimensionStyle()
Dimensions.numdims_for_type(::RealVectorDimensionStyle, ::Type{SVector{N, T}}) where {N, T} = N
Dimensions.numdims(::RealVectorDimensionStyle, x::SVector{N, T}) where {N, T <: Real} = N
Dimensions.getdim(::RealVectorDimensionStyle, x::SVector{N, T}, k) where {N, T <: Real} = x[k]
Dimensions.eachdim(::RealVectorDimensionStyle, x::SVector{N, T}) where {N, T <: Real} = x

end
