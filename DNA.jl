include("Model.jl")

mutable struct DNA
    genes::Vector{Float64}
    fitness::Float64

    function DNA(genes::Vector{Float64})
        new(genes)
    end
end

function fitness(self::DNA, iterations) 
    model = Model(iterations)
    model.xcs = XCS(self.genes[1], self.genes[2], self.genes[3], self.genes[4], self.genes[5], self.genes[6], self.genes[7], self.genes[8], self.genes[9],self.genes[10], self.genes[11], self.genes[12], self.genes[13], self.genes[14], self.genes[15], self.genes[16], self.genes[17],self. genes[18], self.genes[19], self.genes[20])
    population = run(model)
    avg = 0.0
    for p in population
        avg += p.F 
    end

    self.fitness = avg/length(P)
end


function crossover(self::DNA, partner::DNA)
    child = DNA([0.0 for i=1:20])

    midpoint = rand(1:21)

    for i  = 1:length(self.genes)
        if i > midpoint 
            child.genes[i] = self.genes[i]
        else 
            child.genes[i] = partner.genes[i]
        end
    end

    return child 
end

function mutate(self::DNA, mutationRate::Float64) 
    mutationValues = [rand(0.1:0.2), rand(), rand(), rand(25:50), rand(0.5:1.0), rand(0.01:0.05), rand(), rand(), rand(0:1), rand(0:1)]
    index = [2,3,6,7,8,9,11,17,19,20]

    for i = 1:length(mutationValues)
        if rand() < mutationRate
            self.genes[index[i]] = mutationValues[i]
        end
    end
end

# chose the name from the toString methods in Java 
function toString(self::DNA)
    for params in self.genes
        # format the result to easily be able to copy and paste 
        print(round(params, digits=3), ", ")
    end 
    print('\n')
end
