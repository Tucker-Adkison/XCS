include("Classifier.jl")
using Random: shuffle

# Struct to hold all the environment's information
mutable struct Environment 
    dataset
    classifiers 
    count
    cl
    function Environment()
        new([], [], 1)
    end
end

# returns an instance from the list of classifiers
function getSituation(self::Environment)
    if (self.count == length(self.classifiers))
        self.count = 1
    end
    self.cl = self.classifiers[self.count]
    self.count += 1
    return self.cl
end

# initialize the mutliplexer environment
function initializeMUXEnvironment(self::Environment)
    # generate a list of all 6-bit binary numbers 
    binaryNumbers(self, Vector{Char}("000000"), 1, 6)
    self.dataset = shuffle(self.dataset)

    # generate a list of classifiers from each instance in the dataset 
    for bin in self.dataset
        if bin[1] == '0' && bin[2] == '0' 
            push!(self.classifiers, Classifier(bin, parse(Int, bin[3]), 0.0))
        elseif bin[1] == '0' && bin[2] == '1'
            push!(self.classifiers, Classifier(bin, parse(Int, bin[4]), 0.0))
        elseif bin[1] == '1' && bin[2] == '0'
            push!(self.classifiers, Classifier(bin, parse(Int, bin[5]), 0.0))
        else 
            push!(self.classifiers, Classifier(bin, parse(Int, bin[6]), 0.0))
        end
    end
end 

# initialize the boolean NAND problem environment
function initializeNANDEnvironment(self::Environment)
    binaryNumbers(self, Vector{Char}("00"), 1, 2)
    
    # generate a list of classifiers from each instance in the dataset 
    for bin in self.dataset
        if (bin != "11")
            push!(self.classifiers, Classifier(bin, 1, 0.0))
        else 
            push!(self.classifiers, Classifier(bin, 0, 0.0))
        end
    end
end

# helper function to generate any k-bit binary number
function binaryNumbers(self::Environment, s, i, n)
    if i == n+1
        push!(self.dataset, deepcopy(s))
        return
    end
    s[i] = '0'
    binaryNumbers(self, s, i+1, n)
    s[i] = '1'
    binaryNumbers(self, s, i+1, n)
end
