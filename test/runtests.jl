using Test
using Dimensions
using StaticArrays: SVector

@enum Tree rowan hazel

# A simple type
struct Position
    x::Float64
    y::Float64
    z::Float64
end
Dimensions.dimstyle(::Type{Position}) = Dimensions.StructDimensionStyle()

# A type where the fields hold different sorts of things
struct Composite
    a::Float64
    b::Tree
end
Dimensions.dimstyle(::Type{Composite}) = Dimensions.StructDimensionStyle()

# A more complex type, where the fields aren't scalars
struct BigType
    position::Position
    complex::Complex{Float64}
end
Dimensions.dimstyle(::Type{BigType}) = Dimensions.StructDimensionStyle()

function test_scalar(x)
    @test dimstyle(typeof(x)) == Dimensions.ScalarDimensionStyle()
    @test numdims(x) == 1
    @test getdim(x, 1) == x
    @test_throws "Dimension 2 does not exist" getdim(x, 2)
    @test collect(eachdim(x)) == [x,]
end

function test_real_vector(x)
    @test dimstyle(typeof(x)) == Dimensions.RealVectorDimensionStyle()
    @test numdims(x) == length(x)
    for k in eachindex(x)
        @test getdim(x, k) == x[k]
    end
    @test_throws "BoundsError" getdim(x, length(x)+1)
    @test collect(eachdim(x)) == x
end

@testset "scalars" begin
    test_scalar(1)
    test_scalar(rowan)
end

@testset "complex" begin
    x = 3.0 + 4.0im
    @test dimstyle(typeof(x)) == Dimensions.ComplexDimensionStyle()
    @test numdims(x) == 2
    @test getdim(x, 1) == real(x)
    @test getdim(x, 2) == imag(x)
    @test_throws "Dimension 3 does not exist" getdim(x, 3)
    @test collect(eachdim(x)) == [3., 4.]
end

@testset "vectors" begin
    test_real_vector([1., 2., 3.])
    test_real_vector([4,])
    test_real_vector(Float64[])
    test_real_vector(1:3)
    test_real_vector(@view [1., 2., 3.][2:3])
    test_real_vector(SVector{3, Float64}(1., 2., 3.))
end

@testset "numdims_for_type" begin
    @test numdims_for_type(Float64) == 1
    @test numdims_for_type(ComplexF64) == 2
    @test numdims_for_type(Tree) == 1
    @test numdims_for_type(Position) == 3
    @test numdims_for_type(Composite) == 2
    @test numdims_for_type(BigType) == 5
    @test numdims_for_type(SVector{3, Float64}) == 3
    @test_throws ArgumentError numdims_for_type(Vector{Float64})
    @test_throws ArgumentError numdims_for_type(1)
end

@testset "unsupported types" begin
    @test dimstyle(String) == Dimensions.UnknownDimensionStyle()
    @test_throws ArgumentError numdims("hello")
    @test_throws ArgumentError getdim("hello", 1)
    @test_throws ArgumentError eachdim("hello")
    @test_throws ArgumentError numdims([1 2; 3 4])
    @test_throws ArgumentError numdims_for_type(String)
end

@testset "structs" begin

    values = [1.1, 2.2, 3.3]
    x = Position(values...)
    @test dimstyle(typeof(x)) == Dimensions.StructDimensionStyle()
    @test numdims(x) == 3
    for k in eachindex(values)
        @test getdim(x, k) == values[k]
    end
    @test_throws "Dimension 4 does not exist" getdim(x, 4)
    @test collect(eachdim(x)) == values

    values = [float(pi), hazel]
    x = Composite(values...)
    @test dimstyle(typeof(x)) == Dimensions.StructDimensionStyle()
    @test numdims(x) == 2
    for k in eachindex(values)
        @test getdim(x, k) == values[k]
    end
    @test_throws "Dimension 3 does not exist" getdim(x, 3)
    @test collect(eachdim(x)) == values

    x = BigType(Position(1., 2., 3.), 4. + 5im)
    @test dimstyle(typeof(x)) == Dimensions.StructDimensionStyle()
    @test numdims(x) == 5
    for k in 1:5
        @test getdim(x, k) == float(k)
    end
    @test_throws "Dimension 6 does not exist" getdim(x, 6)
    @test collect(eachdim(x)) == collect(1. : 5.)

end
