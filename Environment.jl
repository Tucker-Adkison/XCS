include("Classifier.jl")
using Random: shuffle

# Struct to hold all the environment's information
mutable struct Environment 
    dataset
    test 
    train
    count
    cl
    function Environment()
        new([], [], [], 1)
    end
end

# Adds 64 classifiers to the cl list. Each classifier
# has a different 6-bit binary number and the action 
# associated with that number

function getSituation(self::Environment)
    if (self.count == length(self.train))
        self.count = 1
    end
    self.cl = self.train[self.count]
    self.count += 1
    return self.cl
end

function initializeEnvironment(self::Environment)
    binaryNumbers(self, Vector{Char}("000000"), 1, 6)
    self.dataset = shuffle(self.dataset)
    for i = 1:length(self.dataset)
        self.dataset[i] = Classifier(self.dataset[i], getAction(self, self.dataset[i]) , 0.0)
    end

    size = Int(floor(0.8 * length(self.dataset)))
    self.train = self.dataset[1:size]
    self.test = self.dataset[size+1:end]
end 

# helper function to determin the classifier's action
function getAction(self::Environment, cl)
    f = cl[1]
    s = cl[2]

    if f == '0' && s == '0'
        return parse(Int, cl[3])
    elseif f == '0' && s == '1'
        return parse(Int, cl[4])
    elseif f == '1' && s == '0'
        return parse(Int, cl[5])
    else 
        return parse(Int, cl[6])
    end
end

# helper function to generate all 6-bit binary numbers
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
