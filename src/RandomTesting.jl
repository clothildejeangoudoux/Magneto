# RandomTesting.jl
module RandomTesting

using IntervalArithmetic
using DataStructure
using RPFile
using TestFunctions
using Magneto
using Random
using PrintConstraint

export random_testing

# --- RANDOM TEST GENERATION -----
function random_test_generation(constraint::DataConstraint)    

    test_variables = []
    for i = 1:length(constraint.dataVariables)-1
        var = deepcopy(constraint.dataVariables[i+1])
        test_variables = append!(test_variables,[var])
    end
    
    for i = 1:length(test_variables)
        test_variables[i].dataValue = constraint.dataVariables[i+1].dataValue.lo + (rand(Float64,1)[1] * (constraint.dataVariables[i+1].dataValue.hi - constraint.dataVariables[i+1].dataValue.lo + 1))
    end
    
    y = pick_test(constraint,test_variables)
    return DataTest(test_variables,y)
end

function random_testing(constraint::DataConstraint,mutants,timer =Timer(1.0))
    
    test_set=[]
    test_set_temp=[]
    i=0
    k = 0
    u = 0
    k_temp = 0
    u_temp = 0

    # println("------ CONSTRAINT --------\n")
    # print_constraint(constraint)
    # println("------ MUTANTS --------\n")
    # for i in mutants
    #     print_constraint(i)
    # end
    
    while true
        test = random_test_generation(constraint)
        test_set_temp = append!(test_set_temp,[test])
        k_temp,u_temp = mutation_score(test_set_temp,mutants)
        i += 1
        if (k_temp > k)
            test_set = append!(test_set,[test])
            k = k_temp
            u = u_temp
        end
        isopen(timer) || break
        if k == 1.0
            break
        end
        yield()
    end
    
    return i, test_set,k, u
end

end
