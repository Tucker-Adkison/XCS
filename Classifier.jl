mutable struct Classifier 
    C::Vector{Char}
    A::Char
    p::Float64

    # additional parameters 
    ε::Float64
    F::Float64
    exp::Int
    ts::Float64
    as::Float64
    n::Int

    # constructor 
    function Classifier(C::Vector{Char}, A::Char, p::Float64)
        new(C, A, p, 0.0, 0.0, 0, 0.0, 0.0, 0)
    end
end

function updateC(class::Classifier, C::Vector{Char})
    Classifier.C = C
end

function updateA(class::Classifier, A::Char)
    Classifier.A = A
end

function updatep(class::Classifier, p::Float64)
    Classifier.p = p
end

function updateε(class::Classifier, ε::Float64)
    Classifier.ε = ε
end

function updateF(class::Classifier, F::Float64)
    Classifier.F = F
end

function updateexp(class::Classifier, exp::Int)
    Classifier.exp = exp
end

function updatets(class::Classifier, ts::Float64)
    Classifier.ts = ts
end

function updateas(class::Classifier, as::Float64)
    Classifier.as = as
end

function updaten(class::Classifier, n::Int)
    Classifier.n = n
end

Classifier(Vector{Char}("0100100"), '1', 0.0)

