include("Classifier.jl")
include("Environment.jl")

function runExperiment()
    P = Set()
    p1 = 0
    while (true)
        σ = getSituation(env)
        M = generateMatchSet(P, σ)
        if (true) #terminating criteria
            break
        end
    end
end

function generateMatchSet(P, σ)
    M = Set()
    while (length(M) == 0)
        for i = 1:length(P)
            cl = P[i]
            if doesMatch(cl, σ)
                push!(M, cl)
            end
        end
        temp =  Set()
        for j = 1:length(M)
            if M[j].A ∉ temp
                push!(M[j].A)
            end
        end
        if (length(temp) < θmna)
            clc = generateCovering(M, σ)
            push!(P, clc)
            P = deleteFromPopulation(P)
            M = Set()
        end
    end
    return M
end
env = Environment()
initializeEnvironment(env)
#todo Initialize reinforcement program
#Initializing XCS parameters
N = 500
β = 0.15 # 0.1-0.2
α = 0.1 
ε0 = 10  # 10% of p
ν = 5
γ = 0.71
θGA = 35 # 25-50
χ = 0.7  # 0.5-1.0
μ = 0.03 # 0.01-0.05
θdel = 20
δ = 0.1
θsub = 20
Phash = 0.33
pI = 0.000001 # essentially 0
εI = 0.000001
FI = 0.000001
pexplr = 0.5
θmna = 2 # number of available actions. I.E. {0,1}
doGASubsumption = false
doActionSetSubsumption = false
runExperiment()