
# Struct to hold all the Classifier's paramters 
mutable struct Classifier 
    C::Vector{Char}
    A::Int
    p::Float64

    # additional parameters 
    ε::Float64
    F::Float64
    exp::Int
    ts::Float64
    as::Float64
    n::Int

    # constructor 
    function Classifier(C::Vector{Char}, A::Int, p::Float64)
        new(C, A, p, 0.0, 0.0, 0, 0.0, 0.0, 0)
    end
end