using Test
@testset "Map" begin
    include("map.jl")
end
@testset "Zeros" begin
    include("zeros.jl")
end
@testset "FlipSign" begin
    include("flip_sign.jl")
end
@testset "RSOCtoPSD" begin
    include("rsoc_to_psd.jl")
end
