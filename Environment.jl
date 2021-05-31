include("Classifier.jl")

# Struct to hold all the environment's information
mutable struct Environment 
    cl
    i::Int
Int, 
    function Environment()
        new([], 1)
    end

end

# Adds 64 classifiers to the cl list. Each classifier
# has a different 6-bit binary number and the action 
# associated with that number

function getSituation(self::Environment)
    env = self.cl[self.i]
    if (self.i > length(self.cl))
        self.i = 1
    else 
        self.i += 1
    end 
    return env
end

function initializeEnvironment(self::Environment)
    binaryNumbers(self, Vector{Char}("000000"), 1, 6)
    for i = 1:length(self.cl)
        self.cl[i] = Classifier(self.cl[i], getAction(self, self.cl[i]) , 0.0)
    end
end 

function executeAction(self::Environment, act)
    return 
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
        push!(self.cl, deepcopy(s))
        return
    end
    s[i] = '0'
    binaryNumbers(self, s, i+1, n)
    s[i] = '1'
    binaryNumbers(self, s, i+1, n)
end
