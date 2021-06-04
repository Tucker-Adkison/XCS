mutable struct XCS
    N::Int
    β::Float64 # 0.1-0.2
    α::Float64
    ε0::Int  # 10% of p
    ν::Int
    γ::Float64
    θGA::Int # 25-50
    χ::Float64# 0.5-1.0
    μ::Float64 # 0.01-0.05
    θdel::Int
    δ::Float64
    θsub::Int
    Phash::Float64
    pI::Float64 # essentially 0
    εI::Float64 # essentially 0
    FI::Float64 # essentially 0
    pexplr::Float64
    θmna::Int # number of available actions. I.E. {0,1}
    doGASubsumption::Bool
    doActionSetSubsumption::Bool

    function XCS(N, β, α, ε0, ν, γ, θGA, χ, μ, θdel, δ, θsub, Phash, pI, εI, FI, pexplr, θmna, doGASubsumption, doActionSetSubsumption)
        new(N, β, α, ε0, ν, γ, θGA, χ, μ, θdel, δ, θsub, Phash, pI, εI, FI, pexplr, θmna, doGASubsumption, doActionSetSubsumption)
    end
end