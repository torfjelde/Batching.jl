using ChainRulesCore: ChainRulesCore

function ChainRulesCore.rrule(::Type{A}, xs) where {A<:VectorBatch}
    # TODO: Maybe just use `size` and `A` in `_reconstruct` to
    # avoid closing over the values, which are not necessary?
    ys = A(xs)
    function VectorBatch_pullback(Δbatch)
        return ChainRulesCore.NoTangent(), Batching.value(Δbatch)
    end
    return ys, VectorBatch_pullback
end

_reconstruct(xs::VectorBatch, Δbatch::VectorBatch) = Batching.value(Δbatch)
_reconstruct(xs::ArrayBatch, Δbatch::ArrayBatch) = Batching.value(Δbatch)
function _reconstruct(xs::ArrayBatch, Δbatch::AbstractVector)
    # Create the wanted container from `xs`, copy from `Δbatch` into newly
    # created container, and then return the resulting `value` of that.

    # NOTE: This will allocate even if `eltype(Δbatch)` is a `FillArray`.
    # TODO: Should we have special rules for `FillArray`?
    Batching.value(copyto!(similar(xs), Δbatch))
end

function ChainRulesCore.rrule(::Type{A}, xs) where {A<:ArrayBatch}
    # TODO: Maybe just use `size` and `A` in `_reconstruct` to
    # avoid closing over the values, which are not necessary?
    ys = A(xs)
    function ArrayBatch_pullback(Δbatch)
        return ChainRulesCore.NoTangent(), _reconstruct(ys, ChainRulesCore.unthunk(Δbatch))
    end
    return ys, ArrayBatch_pullback
end
