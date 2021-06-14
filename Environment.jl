include("Classifier.jl")

# Struct to hold all the environment's information
mutable struct Environment 
    clArr
    cl
    function Environment()
        new([])
    end

end

# Adds 64 classifiers to the cl list. Each classifier
# has a different 6-bit binary number and the action 
# associated with that number

function getSituation(self::Environment)
    self.cl = self.clArr[rand(1:length(self.clArr))]
    return self.cl
end

function initializeEnvironment(self::Environment)
    binaryNumbers(self, Vector{Char}("000000"), 1, 6)
    for i = 1:length(self.clArr)
        self.clArr[i] = Classifier(self.clArr[i], getAction(self, self.clArr[i]) , 0.0)
    end
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
        push!(self.clArr, deepcopy(s))
        return
    end
    s[i] = '0'
    binaryNumbers(self, s, i+1, n)
    s[i] = '1'
    binaryNumbers(self, s, i+1, n)
end
