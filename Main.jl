include("Classifier.jl")
include("Environment.jl")
include("Reinforcement.jl")
include("XCS.jl")

function runExperiment()
    PSet = []
    ρ1 = 0
    A1 = Set()
    t = 0
    while (true)
        σ = getSituation(env)
        M = generateMatchSet(PSet, σ, t)
        PA = generatePredictionArray(M)
        act = selectAction(PA)
        A = generateActionSet(M, act)
        ρ = getReward(rp, env, act)
        if(!isempty(A1))
            P = ρ1 + xcs.γ * max(PA...)
            A1 = updateSet(A1, P, PSet)
            PSet = runGA(A1,  σ, PSet, t)
        end

        if (rp.eop)
            P = ρ
            A = updateSet(A, P, PSet)
            PSet = runGa(A, σ, PSet, t)
            A1 = Set()
        else 
            A1 = A
            ρ1 = ρ
            σ1 = σ
        end
        if (t == iterations) #terminating criteria
            return M
        end
        t += 1
    end
end

function generateMatchSet(P, σ, t)
    M = Set()
    while (isempty(M))
        for cl in P
            if doesMatch(cl, σ)
                push!(M, cl)
            end
        end
        temp =  Set()
        for cl in M
            if cl.A ∉ temp
                push!(temp, cl.A)
            end
        end
        if (length(temp) < xcs.θmna)
            clc = generateCoveringClassifier(M, σ, t)
            push!(P, clc)
            P = deleteFromPopulation(P)
            M = Set()
        end
    end
    return M
end

function doesMatch(cl, σ)
    for i = 1:length(cl.C)
        x = cl.C[i]
        if (x != '#' && x != σ.C[i])
            return false 
        end
    return true
    end
end

function generateCoveringClassifier(M, σ, t)
    cl = Classifier(Vector{Char}("000000"), 0, 0.0)
    for i = 1:length(cl.C)
        if (rand() < xcs.Phash)
            cl.C[i] = '#'
        else 
            cl.C[i] = σ.C[i]
        end
    end

    temp = Set()
    for cl in M
        push!(temp, cl.A)
    end

    cl.A = 1 ∉ temp ? 1 : 0
    cl.p = xcs.pI
    cl.ε = xcs.εI
    cl.F = xcs.FI
    cl.exp = 0
    cl.ts = t
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
    for c in P
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

function generatePredictionArray(M)
    PA = [0.0, 0.0]
    FSA = [0.0, 0.0]
    for cl in M
        if (PA[cl.A+1] == 0.0)
            PA[cl.A+1] = cl.p * cl.F
        else 
            PA[cl.A+1] = PA[cl.A+1] + cl.p * cl.F
        end
        FSA[cl.A+1] = FSA[cl.A+1] + cl.F 
    end

    A = [0, 1]
    for i = 1:2
        if (FSA[A[i]+1] != 0.0)
            PA[A[i]+1] = Float64(PA[A[i]+1] / FSA[A[i]+1])
        end
    end
    return PA

end

function selectAction(PA)
    if (rand() < xcs.pexplr)
        return PA[rand(1:length(PA))]
    else 
        return PA[1] > PA[2] ? 0 : 1
    end
end

function generateActionSet(M, act)
    A = Set()
    for cl in M
        if (cl.A == act)
            push!(A, cl)
        end
    end
    return A
end

function updateSet(A, P, PSet)
    for cl in A
        cl.exp += 1
        if (cl.exp < 1/xcs.β)
            cl.p = cl.p + (P - cl.p) / cl.exp
        else 
            cl.p = cl.p + xcs.β * (P - cl.p)
        end

        if (cl.exp < 1/xcs.β)
            cl.ε = cl.ε + (abs(P - cl.p) - cl.ε) / cl.exp
        else
            cl.ε = cl.ε + xcs.β * (abs(P - cl.p) - cl.ε)
        end

        cnSum = 0.0
        for cl in A
            cnSum += cl.n
        end
        if (cl.exp < 1/xcs.β)
            cl.as = cl.as + (cnSum - cl.as) / cl.exp
        else 
            cl.as = cl.as + xcs.β * (cnSum - cl.as)
        end
    end
    A = updateFitness(A)
    if (xcs.doActionSetSubsumption)
        P = doActionSetSubsumption(A, PSet)
    end
    return A
end

function updateFitness(A)
    accuracySum = 0 
    k = []
    for i = 1:length(A)
        push!(k, 0.0)
    end
    i = 1
    for cl in A
        if (cl.ε < xcs.ε0)
            k[i] = 1
        else 
            k[i] = xcs.α * (cl.ε / xcs.ε0) ^ (-xcs.ν)
        end
        accuracySum = accuracySum + k[i] * cl.n 
        i += 1
    end
    i = 1
    for cl in A
        cl.F = cl.F + xcs.β * (k[i] * cl.n / accuracySum - cl.F)
        i += 1
    end
    return A
end

function runGA(A, σ, P, t)
    tsnSum = 0.0
    nSum = 0.0
    for cl in A 
        tsnSum += cl.ts * cl.n
        nSum += cl.n 
    end
    if (t - tsnSum / nSum > xcs.θGA)
        for cl in A 
            cl.ts = t 
        end
        parent1 = selectOffspring(A)
        parent2 = selectOffspring(A)
        child1 = deepcopy(parent1)
        child2 = deepcopy(parent2)
        child1.n = 1
        child2.n = 1 
        child1.exp = 0
        child2.exp = 0 
        if (rand() < xcs.χ)
            child1, child2 = applyCrossover(child1, child2)
            child1.p = (parent1.p + parent2.p) / 2 
            child1.ε = (parent1.ε + parent2.ε) / 2
            child1.F = (parent1.F + parent2.F) / 2
            child2.p = child1.p
            child2.ε = child1.ε
            child2.F = child1.F 
        end
        child1.F = child1.F * 0.1 
        child2.F = child2.F * 0.1 
        childArr = [child1, child2]
        for child in childArr
            child = applyMutation(child, σ)
            if (xcs.doGASubsumption)
                if (doesSubsume(parent1, child))
                    parent1.n += 1
                elseif (doesSubsume(parent2, child))
                    parent2.n += 1
                else 
                    push!(P, child)
                end
            else 
                push!(P, child)
            end 
        end
        P = deleteFromPopulation(P)
    end
    return P
end

function selectOffspring(A)
    fitnessSum = 0 
    for cl in A 
        fitnessSum = fitnessSum + cl.F 
    end
    choicePoint = rand() * fitnessSum 
    fitnessSum = 0 
    for cl in A 
        fitnessSum = fitnessSum + cl.F 
        if (fitnessSum > choicePoint)
            return cl 
        end
    end
end

function applyCrossover(cl1, cl2)
    x = rand() * (length(cl1.C) + 1)
    y = rand() * (length(cl1.C) + 1)
    if (x > y)
        temp = x 
        x = y 
        y = temp 
    end
    i = 1
    while (true)
        if (x <= i && i < y)
            temp = cl1.C[i]
            cl1.C[i] = cl2.C[i]
            cl2.C[i] = temp 
        end
        i += 1
        if (i > y)
            break 
        end
    end
    return cl1, cl2
end

function applyMutation(cl, σ)
    i = 1 
    while (true)
        if (rand() < xcs.μ)
            if (cl.C[i] == '#')
                cl.C[i] = σ.C[i]
            else 
                cl.C[i] = '#'
            end
        end
        i += 1 
        if (i > length(cl.C))
            break 
        end
    end
    if (rand() < xcs.μ)
        cl.A = rand(0:1)
    end

    return cl
end

env = Environment()
initializeEnvironment(env)
rp = Reinforcement()
iterations = 5000
xcs = XCS(iterations, 0.15, 0.1, 10, 5, 0.71, 35, 0.7, 0.03, 20, 0.1, 20, 0.33, 1E-5, 1E-5, 1E-5, 0.5, 2, false, false)
M = runExperiment()
for i in M 
    println(i)
end