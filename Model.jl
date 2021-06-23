include("Classifier.jl")
include("Environment.jl")
include("Reinforcement.jl")
include("XCS.jl")

mutable struct Model 
    env::Environment
    rp::Reinforcement 
    iterations::Int
    time::Int
    population
    xcs::XCS

    function Model(iterations::Int)
        env = Environment()
        rp = Reinforcement()
        xcs = XCS(10000, 0.1, 0.575, 1000.0, 5.0, 0.483, 33.0, 0.5, 0.01, 20.0, 0.739, 20.0, 0.33, 1E-5, 1E-5, 1E-5, 0.572, 2.0, 1.0, 1.0)
        new(env, rp, iterations, 0, [], xcs)
    end
end

function updateParameters(self::Model, xcs::XCS)
    self.xcs = xcs
end

function Base.show(io::IO, self::Model)
    if (length(self.population) == 0)
        print(io, "Population is empty")
        return
    end
    for p in self.population
        println(io, p.C, " -> ", p.A)
        println(io, "\tTime Stamp: ", p.ts)
        println(io, "\tAverage Reward: ", p.p)
        println(io, "\tError: ", p.ε)
        println(io, "\tFitness: ", p.F)
        println(io, "\tExperience: ", p.exp)
        println(io, "\tAction Size Set: ", p.as)
        println(io, "\tNumerosity: ", p.n)
    end
end

function Base.iterate(self::Model, state=1) 
    if (state >= length(self.population))
        return nothing 
    end
    return (self.population[state], state+1)
end

function run(self::Model)
    if (self.env.initialized == false)
        println("Environment not initialized")
        return 
    end

    population = []
    prevReward = 0
    prevActionSet = Set()
    while (true)
        situation = getSituation(self.env)
        matchSet = generateMatchSet(self, population, situation)
        predictionArr = generatePredictionArray(self, matchSet)
        action = selectAction(self, predictionArr)  
        actionSet = generateActionSet(self, matchSet, action)
        reward = getReward(self.rp, self.env, action)
        if(!isempty(prevActionSet))
            payoff = prevReward + self.xcs.γ * max(predictionArr...)
            updateSet(self, prevActionSet, payoff, population)
            runGA(self, prevActionSet, situation, population)
        end

        if (self.rp.eop)
            payoff = reward
            updateSet(self, actionSet, payoff, population)
            runGA(self, actionSet, situation, population)
            prevActionSet = Set()
        else 
            prevActionSet = deepcopy(actionSet)
            prevReward = reward
            situation = situation
        end

        if (self.time == self.iterations)
            self.population = population 
            return self.population
        end 

        self.time += 1
    end
end

function generateMatchSet(self, population, situation)
    matchSet = Set()
    while (isempty(matchSet ))
        for cl in population
            if doesMatch(self, cl, situation)
                push!(matchSet , cl)
            end
        end

        actions =  Set()
        for cl in matchSet 
            push!(actions, cl.A)
        end

        if (length(actions) < self.xcs.θmna)
            push!(population, generateCoveringClassifier(self ,matchSet, situation))
            deleteFromPopulation(self, population)
            matchSet = Set()
        end
    end
    return matchSet  
end

function doesMatch(self, cl, situation)
    for i = 1:length(cl.C)
        bin = cl.C[i]
        if (bin != '#' && bin != situation.C[i])
            return false 
        end
    return true
    end
end

function generateCoveringClassifier(self, matchSet, situation)
    cl = Classifier(Vector{Char}(), 0, 0.0)
    for bin in situation.C
        if (rand() < self.xcs.Phash)
            push!(cl.C, '#')
        else 
            push!(cl.C, bin) 
        end
    end

    matchActions = Set()
    for cl in matchSet
        push!(matchActions, cl.A)
    end
    
    if (isempty(matchActions))
        cl.A = rand(self.env.actions)
    else 
        cl.A = rand(setdiff(self.env.actions, matchActions))
    end
    cl.p = self.xcs.pI
    cl.ε = self.xcs.εI
    cl.F = self.xcs.FI
    cl.exp = 0
    cl.ts = self.time
    cl.as = 1
    cl.n = 1

    return cl
end

function insertInPopulation(self, cl, population)
    for c in population
        if (c.C == cl.C && c.A == cl.A)
            c.n += 1 
            return 
        end
    end
    push!(population, cl)
end

function deleteFromPopulation(self, population)
    numerositySum = 0
    fitnessSum = 0
    for p in population
        numerositySum += p.n
        fitnessSum += p.F
    end
    if numerositySum <= self.xcs.N
        return
    end
    avFtinessInPopulation = fitnessSum/numerositySum 
    voteSum = 0 
    for cl in population
        voteSum += deletionVote(self, cl, avFtinessInPopulation)
    end
    choicePoint = rand() * voteSum
    voteSum = 0
    for cl in population
        voteSum += deletionVote(self, cl, avFtinessInPopulation)
        if (voteSum > choicePoint)
            if (cl.n > 1)
                cl.n -= 1
            else 
                filter!(e->e≠cl, population)
            end
            return 
        end
    end
end

function deletionVote(self, cl, avFtinessInPopulation)
    vote = cl.as * cl.n 
    if (cl.exp > self.xcs.θdel && cl.F / cl.n < self.xcs.δ * avFtinessInPopulation)
        vote *= avFtinessInPopulation / (cl.F / cl.n)
    end
    return vote
end

function generatePredictionArray(self, M)
    predictionArr = Dict()
    fitnessSumArr = Dict()

    for action in self.env.actions
        predictionArr[action] = 0.0
        fitnessSumArr[action] = 0.0
    end

    for cl in M
        if (predictionArr[cl.A] == 0.0)
            predictionArr[cl.A] = cl.p * cl.F
        else 
            predictionArr[cl.A] += cl.p * cl.F
        end
        fitnessSumArr[cl.A] += cl.F 
    end

    for action in self.env.actions
        if (fitnessSumArr[action] != 0.0)
            predictionArr[action] = Float64(predictionArr[action] / fitnessSumArr[action])
        end
    end
    return predictionArr
end

function selectAction(self, predictionArr)
    if (rand() < self.xcs.pexplr)
        filter(e -> e != 0.0, predictionArr)
        if (length(predictionArr) == 0)
            return rand(self.env.actions)
        end
        return rand(keys(predictionArr))
    else 
        bestVal = -1
        bestAction = -1
        for action in self.env.actions
            if (predictionArr[action] > bestVal)
                bestVal = predictionArr[action]
                bestAction = action 
            end
        end
        return bestAction
    end
end

function generateActionSet(self, matchSet, action)
    actionSet = Set()
    for cl in matchSet
        if (cl.A == action)
            push!(actionSet, cl)
        end
    end
    return actionSet
end

function updateSet(self, actionSet, payoff, population)
    for cl in actionSet
        cl.exp += 1
        if (cl.exp < 1/self.xcs.β)
            cl.p += (payoff - cl.p) / cl.exp
        else 
            cl.p += self.xcs.β * (payoff - cl.p)
        end

        if (cl.exp < 1/self.xcs.β)
            cl.ε += (abs(payoff - cl.p) - cl.ε) / cl.exp
        else
            cl.ε += self.xcs.β * (abs(payoff - cl.p) - cl.ε)
        end

        numerositySum = 0.0
        for cl in actionSet
            numerositySum += cl.n
        end
        if (cl.exp < 1/self.xcs.β)
            cl.as += (numerositySum - cl.as) / cl.exp
        else 
            cl.as += self.xcs.β * (numerositySum - cl.as)
        end
    end
    updateFitness(self, actionSet)
    if (self.xcs.doActionSetSubsumption)
        doActionSetSubsumption(self, actionSet, population)
    end
end

function updateFitness(self, actionSet)
    accuracySum = 0 
    accuracy = Dict()
    for cl in actionSet
        if (cl.ε < self.xcs.ε0)
            accuracy[cl] = 1
        else 
            accuracy[cl] = self.xcs.α * ((cl.ε / self.xcs.ε0) ^ (-self.xcs.ν))
        end
        accuracySum += accuracy[cl] * cl.n 
    end
    for cl in actionSet
        cl.F = cl.F + self.xcs.β * (accuracy[cl] * cl.n / accuracySum - cl.F)
    end
end

function runGA(self, actionSet, situation, population)
    timeNumserositySum = 0.0
    numerositySum = 0.0
    for cl in actionSet
        timeNumserositySum += cl.ts * cl.n
        numerositySum += cl.n 
    end
    if (self.time - (timeNumserositySum / numerositySum) > self.xcs.θGA)
        for cl in actionSet 
            cl.ts = self.time
        end
        parent1 = selectOffspring(self, actionSet)
        parent2 = selectOffspring(self, actionSet)
        child1 = deepcopy(parent1)
        child2 = deepcopy(parent2)
        child1.n = 1
        child2.n = 1 
        child1.exp = 0
        child2.exp = 0 
        if (rand() < self.xcs.χ)
            child1, child2 = applyCrossover(self, child1, child2)
            child1.p = (parent1.p + parent2.p) / 2 
            child1.ε = (parent1.ε + parent2.ε) / 2
            child1.F = (parent1.F + parent2.F) / 2
            child2.p = child1.p
            child2.ε = child1.ε
            child2.F = child1.F 
        end
        child1.F *= 0.1 
        child2.F *= 0.1 
        childArr = [child1, child2]
        for child in childArr
            child = applyMutation(self, child, situation)
            if (self.xcs.doGASubsumption)
                if (doesSubsume(self, parent1, child))
                    parent1.n += 1
                elseif (doesSubsume(self,parent2, child))
                    parent2.n += 1
                else 
                    insertInPopulation(self, child, population)
                end
            else 
                insertInPopulation(self, child, population)
            end 
        end
        deleteFromPopulation(self, population)
    end
end

function selectOffspring(self, actionSet)
    fitnessSum = 0 
    for cl in actionSet 
        fitnessSum += cl.F 
    end
    choicePoint = rand() * fitnessSum 
    fitnessSum = 0 
    for cl in actionSet 
        fitnessSum += cl.F 
        if (fitnessSum > choicePoint)
            return cl 
        end
    end
end

function applyCrossover(self, cl1, cl2)
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
        if (i >= y)
            break 
        end
    end
    return cl1, cl2
end

function applyMutation(self, cl, situation)
    i = 1 
    while (true)
        if (rand() < self.xcs.μ)
            if (cl.C[i] == '#')
                cl.C[i] = situation.C[i]
            else 
                cl.C[i] = '#'
            end
        end
        i += 1 
        if (i >= length(cl.C))
            break 
        end
    end
    if (rand() < self.xcs.μ)
        cl.A = rand(self.env.actions)
    end
    return cl
end

function doActionSetSubsumption(self, actionSet, population)
    cl = Classifier(Vector{Char}(""), 0, 0.0)
    for c in actionSet
        if (couldSubsume(self, c))
            clhash = 0 
            chash = 0 
            if (length(cl.C) > 1)
                for i in c.C
                    if (i == '#')
                        chash += 1 
                    end
                end
                for i in cl.C
                    if (i == '#')
                        clhash += 1 
                    end
                end
            end
            if (length(cl.C) == 0 || chash > clhash || (chash == clhash && rand() < 0.5))
                cl = c  
            end
        end
    end 
    if (length(cl.C) != 0)
        for c in actionSet
            if (isMoreGeneral(self, c, cl))
                cl.n = cl.n + c.n 
                filter!(e->e≠c, population)
                filter!(e->e≠c, actionSet)    
            end
        end
    end
end 

function couldSubsume(self, cl)
    if (cl.exp > self.xcs.θsub)
        if (cl.ε < self.xcs.ε0)
            return true 
        end
    end
    return false 
end

function isMoreGeneral(self, clgen, clspec)
    clgenhash = 0
    clspechash = 0
    for i in clgen.C
        if i == '#'
            clgenhash += 1
        end
    end

    for i in clspec.C
        if i == '#' 
            clspechash += 1 
        end
    end

    if (clgenhash <= clspechash)
        return false 
    end
    i = 1
    while (true) 
        if (clgen.C[i] != '#' && clgen.C[i] != clspec.C[i])
            return false 
        end
        i += 1
        if (i >= length(clgen.C))
            break 
        end
    end
    
    return true 
end

function(self, clsub, cltos)
    if (clsub.A == cltos.A)
        if (couldSubsume(self, clsub))
            if (isMoreGeneral(self, cltos, clsub))
                return true 
            end
        end
    end  
    return false 
end

function doesSubsume(self, clsub, cltos)
    if (clsub.A == cltos.A)
        if (couldSubsume(self, clsub))
            if (isMoreGeneral(self, cltos, clsub))
                return true 
            end
        end
    end  
    return false 
end