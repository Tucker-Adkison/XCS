include("Model.jl")

model = Model(10000)
run(model)
for i in model
    if(i.F > 0.5)
        println(i)
    end
end