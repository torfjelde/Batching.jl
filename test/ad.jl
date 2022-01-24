@testset "ChainRules" begin
    xs = randn(2, 3)
    T = typeof(batch(xs))
    test_rrule(T, xs)

    # We do not currently handle `Generator`, etc.
    # since there's no `getindex`.
    # In addition, we `collect` here to avoid eltype being `SubArray`
    # which FiniteDifferences.jl isn't too happy with.
    xs = map(collect, eachcol(randn(2, 3)))
    T = typeof(batch(xs))
    test_rrule(T, xs)
end
