include("DNA.jl")

# Genetic algorithm for XCS parameter tuning 

mutationRate = 0.01 
totalPopulation = 150 
population = []
matingPool = [] 

# initialize the population to a set of DNA with randomly generated XCS paramaters 
for i = 1:totalPopulation 
    push!(population, DNA([10000, rand(0.1:0.2), rand(), Int(10000*.10), 5, rand(), rand(25:50), rand(0.5:1.0), rand(0.01:0.05), 20, rand(), 20, rand(), 1E-5, 1E-5, 1E-5, rand(), 2, rand(0:1), rand(0:1)]))
end

function GA(iterations::Int) 
    iterations = UInt(iterations)
    t = 0

    while (true)
        # generate fitness for all classifiers in the population
        for i = 1:length(population)
            fitness(population[i])
        end

        # make a mating pool from the population using roulette selection 
        for i = 1:length(population)
            n = Int(round(population[i].fitness * 100))
            for j = 1:n 
                push!(matingPool, population[i])
            end
        end

        # run until the generation matches the number of iterations,
        # printing the best classifier's values 
        if (t == iterations)
            m = population[1].fitness 
            index = 1 
            for i = 1:length(population)
                if population[i].fitness > m
                    m = population[i].fitness 
                    index = i 
                end 
            end
            println(population[index])
            toString(population[index])
            break 
        end
                
        # apply crossover, putting the children back into the population
        for i = 1:length(population)
            a = rand(1:length(matingPool))
            b = rand(1:length(matingPool))

            parentA = matingPool[a]
            parentB = matingPool[b]
            child = crossover(parentA, parentB)
            mutate(child, mutationRate)

            population[i] = child 
        end

        # debugging to help make sure the algorithm is working 
        println("Generation: ", t)

        t += 1
    end

end

GA(1000)