include("Model.jl")
include("Environment.jl")
model = Model(10000)
# initializeMUXEnvironment(model.env)
run(model)
for i in model
    if(i.F > 0.5)
        println(i)
    end
end