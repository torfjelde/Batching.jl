struct ArrayBatch{T,V<:AbstractArray,EventDim} <: AbstractBatch{T}
    value::V
end

# `batch` constructor.
function batch(xs::AbstractArray{<:Any,N}, ::Val{EventDim}=Val{N}()) where {N,EventDim}
    # HACK: Assumes `output` is non-empty.
    x = getindex_nth(xs, 1, Val{EventDim}())
    return ArrayBatch{typeof(x),typeof(xs),EventDim}(xs)
end

eventdim(::ArrayBatch{<:Any,<:Any,EventDim}) where {EventDim} = EventDim

# `AbstracBatch` interface.
value(x::ArrayBatch) = x.value

# `AbstractVector` interface.
Base.size(batch::ArrayBatch) = (size(value(batch), eventdim(batch)),)

Base.zero(xs::ArrayBatch) = batch(Base.zero(value(xs)), Val{eventdim(xs)}())

# TODO: Will the `...` be compiled away or should we use generated functions?
function getindex_nth(xs::AbstractArray, i, ::Val{N}) where {N}
    I = Base.setindex(axes(xs), i, N)
    return Base.maybeview(xs, I...)
end

Base.getindex(xs::ArrayBatch, i::Integer) = getindex_nth(value(xs), i, Val{eventdim(xs)}())
Base.getindex(xs::ArrayBatch, i) = batch(getindex_nth(value(xs), i, Val{eventdim(xs)}()), Val{eventdim(xs)}())

function Base.setindex!(xs::ArrayBatch, v, i)
    val = value(xs)
    I = Base.setindex(axes(val), i, eventdim(xs))
    return Base.setindex!(val, v, I...)
end

# We can preserve the `ArrayBatch` if the only difference between the current
# `eltype` of the batch and the new `eltype` is the `eltype` of the underlying.
Base.similar(xs::ArrayBatch) = batch(similar(value(xs)), Val{eventdim(xs)}())
function Base.similar(xs::ArrayBatch{<:AbstractArray{S,N}}, ::Type{A}) where {T,S,N,A<:AbstractArray{T,N}}
    val = value(xs)
    return batch(similar(val, size(val)), Val{eventdim(xs)}())
end
function Base.similar(
    xs::ArrayBatch{<:AbstractArray{S,N}},
    ::Type{A},
    len::Union{Integer, AbstractUnitRange}
) where {T,S,N,A<:AbstractArray{T,N}}
    val = value(xs)
    # Here we simply update the event-dim.
    sz_new = Base.setindex(size(val), len, eventdim(xs))
    # TODO: Can we the container type from `A` instead of `xs`?
    return batch(similar(val, eltype(A), sz_new), Val{eventdim(xs)}())
end

function Base.similar(
    xs::ArrayBatch{<:AbstractArray{S,N}},
    ::Type{A},
    dims::Tuple{Union{Integer, Base.OneTo}}
) where {T,S,N,A<:AbstractArray{T,N}}
    val = value(xs)
    sz_new = Base.setindex(size(val), first(dims), eventdim(xs))
    # TODO: Can we the container type from `A` instead of `xs`?
    return batch(similar(val, eltype(A), sz_new), Val{eventdim(xs)}())
end


batch_like(input::ArrayBatch, output::AbstractArray) = batch(output)
batch_like(input::ArrayBatch, output::AbstractVector{<:Real}) = batch(output)
function batch_like(input::ArrayBatch{<:Any, <:AbstractArray{<:Any,N}}, output::AbstractArray{<:Real,N}) where {N}
    # Assumes `output` is non-empty, which seems reasonable here.
    x = getindex_nth(output, 1, Val{eventdim(input)}())
    return ArrayBatch{typeof(x), typeof(output), eventdim(input)}(output)
end


# TODO: Should we instead implement `Broadcast.materialize` to re-wrap the result?
function Broadcast.broadcasted(f::Base.Fix1{typeof(broadcast)}, xs::ArrayBatch)
    return batch_like(xs, f.x.(value(xs)))
end
function Broadcast.broadcast!(f::Base.Fix1{typeof(broadcast)}, xs::ArrayBatch, ys::ArrayBatch)
    Broadcast.broadcast!(f.x, value(xs), value(ys))
    return ys
end
