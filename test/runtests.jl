using Batching
using Test
using ChainRulesCore
using ChainRulesTestUtils

@testset "Batching.jl" begin
    include("constructors.jl")
    include("ad.jl")
end
