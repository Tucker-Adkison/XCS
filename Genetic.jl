include("DNA.jl")

# Genetic algorithm for XCS parameter tuning 

mutationRate = 0.01 
totalPopulation = 150 

# initalValues = [10000, 0.15, 0.1, Int(10000 * .10), 5, 0.71, 35, 0.7, 0.03, 20, 0.1, 20, 0.33, 1E-5, 1E-5, 1E-5, 0.5, 2, false, false]

population = []
matingPool = [] 

for i = 1:totalPopulation 
    push!(population, DNA([10000, rand(0.1:0.2), rand(), Int(10000*.10), 5, rand(), rand(25:50), rand(0.5:1.0), rand(0.01:0.05), 20, rand(), 20, rand(), 1E-5, 1E-5, 1E-5, rand(), 2, rand(0:1), rand(0:1)]))
end

function GA() 
    t = 0
    iterations = 5000

    while (t < iterations)
        for i = 1:length(population)
            fitness(population[i])
        end

        for i = 1:length(population)
            n = Int(round(population[i].fitness * 100))
            for j = 1:n 
                push!(matingPool, population[i])
            end
        end
        
        # println(maximum(cl -> cl.fitness, population))
        for i = 1:length(population)
            a = rand(1:length(matingPool))
            b = rand(1:length(matingPool))

            parentA = matingPool[a]
            parentB = matingPool[b]

            child = crossover(parentA, parentB)
            mutate(child, mutationRate)

            population[i] = child 
        end

        t += 1
    end

    m = population[1].fitness 
    index = 1 
    for i = 1:length(population)
        if population[i].fitness > m
            m = population[i].fitness 
            index = i 
        end 
    end
    println(population[index])
    printValues(population[index])
end

GA()