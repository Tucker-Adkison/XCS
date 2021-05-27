include("Classifier.jl")

mutable struct Environment 
    cls

    function Environment()
        new([])
    end

end

function initializeEnvironment(self::Environment)
    binaryNumbers(self, Vector{Char}("000000"), 1, 6)
    for i = 1:length(self.cls)
        self.cls[i] = Classifier(self.cls[i], getAction(self, self.cls[i]) , 0.0)
    end

end 

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