@testset "constructors" begin
    # Vector
    xs = randn(3)
    @test batch(xs) isa Batching.VectorBatch

    # Matrix (vector of vectors)
    xs = randn(2, 3)
    xs_batch = batch(xs)
    @test xs_batch isa Batching.ArrayBatch
    @test Batching.eventdim(xs_batch) == 2
    @test ndims(eltype(xs_batch)) == 1
    @test length(xs_batch) == size(xs, 2)
    @test all(xs_batch[i] == xs[:, i] for i = 1:length(xs_batch))

    xs_batch = batch(xs, Val(1))
    @test Batching.eventdim(xs_batch) == 1
    @test ndims(eltype(xs_batch)) == 1
    @test length(xs_batch) == size(xs, 1)
    @test all(xs_batch[i] == xs[i, :] for i = 1:length(xs_batch))

    # Higher dimensional arrays
    xs = rand(2, 3, 4)
    xs_batch = batch(xs)
    @test Batching.eventdim(xs_batch) == 3
    @test ndims(eltype(xs_batch)) == 2
    @test length(xs_batch) == size(xs, 3)
    @test all(xs_batch[i] == xs[:, :, i] for i = 1:length(xs_batch))
end
