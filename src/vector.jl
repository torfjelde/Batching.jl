struct VectorBatch{T,V<:AbstractVector{T}} <: AbstractBatch{T}
    value::V
end

batch(xs::AbstractVector) = VectorBatch(xs)
value(xs::VectorBatch) = xs.value

# `AbstractVector` interface.
Base.size(xs::VectorBatch) = size(value(xs))

Base.getindex(xs::VectorBatch, i::Integer) = Base.getindex(value(xs), i)
Base.getindex(xs::VectorBatch, i::Union{AbstractArray,AbstractUnitRange}) = batch(Base.getindex(value(xs), i))
Base.setindex!(xs::VectorBatch, v, i) = Base.setindex!(value(xs), v, i)
