include("Classifier.jl")

# Struct to hold all the environment's information
mutable struct Environment 
    cls

    function Environment()
        new([])
    end

end

# Adds 64 classifiers to the cls list. Each classifier
# has a different 6-bit binary number and the action 
# associated with that number

function initializeEnvironment(self::Environment)
    binaryNumbers(self, Vector{Char}("000000"), 1, 6)
    for i = 1:length(self.cls)
        self.cls[i] = Classifier(self.cls[i], getAction(self, self.cls[i]) , 0.0)
    end

end 

# helper function to determin the classifier's action
function getAction(self::Environment, cls)
    f = cls[1]
    s = cls[2]

    if f == 0 && s == 0
        return cls[3]
    elseif f == 0 && s == 1
        return cls[4]
    elseif f == 1 && s == 0
        return cls[5]
    else 
        return cls[6]
    end
end

# helper function to generate all 6-bit binary numbers
function binaryNumbers(self::Environment, s, i, n)
    if i == n+1
        push!(self.cls, deepcopy(s))
        return
    end
    s[i] = '0'
    binaryNumbers(self, s, i+1, n)
    s[i] = '1'
    binaryNumbers(self, s, i+1, n)
end
