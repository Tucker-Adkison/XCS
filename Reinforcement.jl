mutable struct Reinforcement
    eop::Bool

    function Reinforcement()
        new(true)
    end
end

function getReward(self::Reinforcement, env, act)
    if env.cl.A == act
        return 1000
    else 
        return 0 
    end
end 