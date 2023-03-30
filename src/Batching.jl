module Batching

export batch, batch_like, AbstractBatch

abstract type AbstractBatch{T} <: AbstractVector{T} end

"""
    value(x)

Returns the underlying storage used for the entire batch.

If `x` is not `AbstractBatch`, then this is the identity function.
"""
value(x) = x

# We need to overload the implementations of `similar(::AbstractVector)`
Base.similar(xs::AbstractBatch) = batch(similar(value(xs)))
Base.similar(xs::AbstractBatch, ::Type{T}) where {T} = batch(similar(value(xs), T))
function Base.similar(xs::AbstractBatch, ::Type{T}, I::Union{Integer, AbstractUnitRange}) where {T}
    return batch(similar(value(xs), T, I))
end
function Base.similar(
    xs::AbstractBatch,
    ::Type{T},
    dims::Tuple{Union{Integer, Base.OneTo}, Vararg{Union{Integer, Base.OneTo}}}
) where {T}
    return batch(similar(value(xs), T, dims))
end

# Broadcasting.
Broadcast.BroadcastStyle(::Type{B}) where {B<:AbstractBatch} = Broadcast.ArrayStyle{B}()

function Base.similar(
    bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{B}},
    ::Type{ElType},
    dims
) where {B<:AbstractBatch,ElType}
    return batch(similar(Array{ElType}, dims))
end

"""
    batch_like(input, output)

Return `output` as a batch similar to `input`, if `input` is a batch.

If `input` is not a [`AbstractBatch`](@ref), then `output` is returned.

# Examples
```julia
julia> xs = batch(ones(2, 3))
3-element Batching.ArrayBatch{SubArray{Float64, 1, Matrix{Float64}, Tuple{Base.OneTo{Int64}, Int64}, true}, Matrix{Float64}, 2}:
 [1.0, 1.0]
 [1.0, 1.0]
 [1.0, 1.0]

julia> # Want to specialize `f` on the case of an `ArrayBatch`.
       function f(input::Batching.ArrayBatch)
           # Extract the underlying array.
           input_batch_maybe = Batching.value(input)
           # Broadcast `exp`.
           output_batch_maybe = exp.(input_batch_maybe)
           # Rewrap as a `batch` similar to `input`, e.g. preserving `eventdim(input)`.
           return batch_like(input, output_batch_maybe)
       end
f (generic function with 1 method)

julia> f(xs)
3-element Batching.ArrayBatch{SubArray{Float64, 1, Matrix{Float64}, Tuple{Base.OneTo{Int64}, Int64}, true}, Matrix{Float64}, 2}:
 [2.718281828459045, 2.718281828459045]
 [2.718281828459045, 2.718281828459045]
 [2.718281828459045, 2.718281828459045]
```
"""
batch_like(input, outputs...) = map(Base.Fix1(batch_like, input), outputs)
batch_like(::B, output::B) where {B<:AbstractBatch} = output
batch_like(input::AbstractBatch, output::AbstractArray) = batch(output)

include("vector.jl")
include("array.jl")
include("chainrules.jl")

end
