include("Classifier.jl")
include("Environment.jl")
include("XCS.jl")

function runExperiment()
    P = []
    p1 = 0
    while (true)
        σ = getSituation(env)
        M = generateMatchSet(P, σ)
        println(M)
        if (true) #terminating criteria
            break
        end
    end
end

function generateMatchSet(P, σ)
    M = []
    while (isempty(M))
        for i = 1:length(P)
            cl = P[i]
            if doesMatch(cl, σ)
                push!(M, cl)
            end
        end
        temp =  Set()
        for j = 1:length(M)
            if M[j].A ∉ temp
                push!(temp, M[j].A)
            end
        end
        if (length(temp) < xcs.θmna)
            clc = generateCoveringClassifier(M, σ)
            push!(P, clc)
            P = deleteFromPopulation(P)
            M = []
        end
    end
    return M
end

function doesMatch(cl, σ)
    for i = 1:length(cl.C)
        x = cl.C[i]
        if (x != 'h' && x != σ.C[i])
            return false 
        end
    return true
    end
end

function generateCoveringClassifier(M, σ)
    cl = Classifier(Vector{Char}("000000"), '0', 0.0)
    for i = 1:length(cl.C)
        if (rand() < xcs.Ph)
            cl.C[i] = 'h'
        else 
            cl.C[i] = σ.C[i]
        end
    end

    temp = Set()
    for i = 1:length(M)
        push!(temp, M[i].A)
    end


    cl.A = '1' ∉ temp ? '1' : '0'
    cl.p = xcs.pI
    cl.ε = xcs.εI
    cl.F = xcs.FI
    cl.exp = 0
    cl.ts = 0 # ?
    cl.as = 1
    cl.n = 1

    return cl
end

function deleteFromPopulation(P)
    nSum = 0
    fSum = 0
    for i = 1:length(P)
        nSum += P[i].n 
        fSum += P[i].F
    end
    if nSum <= xcs.N
        return P
    end
    avFtinessInPopulation = fSum/nSum 
    voteSum = 0 
    for i = 1:length(P)
        voteSum += deletionVote(P[i], avFtinessInPopulation)
    end
    choicePoint = rand() * voteSum
    for i = 1:length(P)
        c = P[i]
        voteSum += deletionVote(c, avFtinessInPopulation)
        if (voteSum < choicePoint)
            if (c.n > 1)
                c.n -= 1
            else 
                filter!(e->e≠c, P)
            end
            return P
        end
    end
    return P
end

function deletionVote(cl, avFtinessInPopulation)
    vote = cl.as * cl.n 
    if (cl.exp > xcs.θdel && cl.F < xcs.δ * avFtinessInPopulation)
        vote = vote * avFtinessInPopulation / (cl.F / cl.n)
    end
    return vote
end

env = Environment()
initializeEnvironment(env)
#todo Initialize reinforcement program
xcs = XCS(500, 0.15, 0.1, 10, 5, 0.71, 35, 0.7, 0.03, 20, 0.1, 20, 0.33, 1E-10, 1E-10, 1E-10, 0.5, 2, false, false)
runExperiment()