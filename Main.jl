include("Classifier.jl")
include("Environment.jl")

function runExperiment()
    P = Set()
    p1 = 0
    while (true)
        σ = env.getSituation
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
#todo Initialize XCS 
# runExperiment()