# Magneto.jl
module Magneto

using IntervalArithmetic
using DataStructure
using PrintConstraint
using MutantGeneration
using RPFile
using TestFunctions

export magneto
export gen_test
export test_eval
export mutation_score

# --- MAGNETO TEST GENERATION -----
function gen_test(constraint::DataConstraint,mutant::DataConstraint)    

    # println("GEN TEST")
    # Get exponent
    exponent = -floor(log(10,Float64(constraint.dataRelativeError.dataValue)))
    
    # Generate CSP to generate test according to the type of mutation 
    csp_test = gen_csp_test(constraint, mutant)
    
    for j = Int64(exponent+3):Int64(exponent*2)
        # Execute test csp at absolute precision i
        for i = 1:Int64(length(csp_test)/2)
            file_name = string(csp_test[(i-1)*2+2].dataName,"_test_generation")
            abs_error = 10.0^(-j)
            gen_RPFile_test_generation(csp_test[(i-1)*2+1],csp_test[(i-1)*2+2],abs_error,file_name)
            if (occursin("bound",file_name))
                found_test, inner = is_test_bound(csp_test[(i-1)*2+1],csp_test[(i-1)*2+2])
            else
                found_test, inner = is_test(file_name)
            end
            # One inner box has been found at absolute precision i
            if (found_test == "OK")
                # Parse inner to set values to all input variables
                test_variables = parse_RP_result_pick_input_test(inner,csp_test[(i-1)*2+1],csp_test[(i-1)*2+2],file_name)
                # Pick test, aka y value
                y = pick_test(constraint,test_variables)
                # println(inner)
                # println("should be KO :",test_eval(mutant,DataTest(test_variables,y),"test"))
                return DataTest(test_variables,y)
            elseif (j == exponent*2)
                if (trunc(0.6+rand()) == 1)
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
                # println("should be OK")
                f = open("equivalent_mutants.txt","a")
                println(f,"FAIL GENERATE TEST FOR: ",csp_test[(i-1)*2+2].dataName," AT ABS_PREC: ",abs_error)
                close(f)
                return
            end
        end
    end
end

# --- TEST EVALUATION -----
function test_eval(constraint::DataConstraint,test::DataTest, file_name)

    # prec = Int64(abs(log10(constraint.dataRelativeError.dataValue)))
    # if prec < 2
    #     prec = 2
    # end
    # setprecision(Interval,prec)

    # # eval bounds
    # for i = 1:length(test.dataTestVariables)
    #     if !((test.dataTestVariables[i].dataValue >= constraint.dataVariables[i+1].dataValue.lo) && (test.dataTestVariables[i].dataValue <= constraint.dataVariables[i+1].dataValue.hi))
    #         return "KO"
    #     end
    # end

    # eval valid test
    eval(Meta.parse("y = @interval(-Inf,+Inf)"))
    
    for i in test.dataTestVariables
        eval(Meta.parse(string(i.dataName," = @biginterval(",i.dataValue,")")))
    end
    for i in constraint.dataConstants
        eval(Meta.parse(string(i.dataName," = ",i.dataValue)))
    end

    tree = gen_csp_tree_mutant(constraint.dataRight)
    
    tree_m = Meta.parse(string(tree,"*(1 - e)"))
    tree_p = Meta.parse(string(tree,"*(1 + e)"))

    eval(Meta.parse(string("e = @biginterval(",constraint.dataRelativeError.dataValue,")")))    

    bound_inf = eval(tree_m)
    bound_sup = eval(tree_p)

    if bound_inf.hi > bound_sup.lo
        temp = bound_inf
        bound_inf = bound_sup
        bound_sup = temp
    end
    
    if (isinf(bound_inf.lo)|| isinf(bound_sup.hi))
        return "UNCERTAIN"
    end
    
    if (bound_inf.lo >= test.dataTestResult.dataValid[1].lo) && (bound_sup.hi <= test.dataTestResult.dataValid[1].hi)
        return "OK"
    end
    
    if (bound_sup.hi <= test.dataTestResult.dataInvalid[1].hi)
        return "KO"
    end
    if (bound_inf.lo >= test.dataTestResult.dataInvalid[2].lo)
        return "KO"
    end

    if (bound_sup.hi >= test.dataTestResult.dataInvalid[2].lo)
        if (abs(bound_sup.hi - test.dataTestResult.dataInvalid[2].lo) >= constraint.dataRelativeError.dataValue*(1+PREC_MUT_ERR))
            return "KO"
        end
    end

    if (bound_inf.lo >= test.dataTestResult.dataInvalid[1].hi)
        if (abs(bound_inf.lo - test.dataTestResult.dataInvalid[1].hi) >= constraint.dataRelativeError.dataValue*(1+PREC_MUT_ERR))
            return "KO"
        end
    end

    # verdict = "OK"

    # if (trunc(0.35+rand()) == 1)
    #     gen_RPFile_test_evaluation(constraint,test,Float64(constraint.dataRelativeError.dataValue)*10.0^-1,file_name)
        
    #     if (trunc(0.15+rand()) == 1)
    #         verdict = "OK"
    #         if test.dataTestResult.dataValid != nothing
    #             verdict, res = verdict_test_file(string(file_name,"_valid"),1)
    #             if verdict == "KO"
    #                 return verdict
    #             end
    #         end
    #     end
        
    #     if (trunc(0.15+rand()) == 1)
    #         if test.dataTestResult.dataInvalid[1] != nothing
    #             verdict, res = verdict_test_file(string(file_name,"_invalid1"),0)
    #             if verdict == "KO"
    #         return verdict
    #             end
    #         end
    #     end
        
    #     if (trunc(0.15+rand()) == 1)
    #         if test.dataTestResult.dataInvalid[2] != nothing
    #             verdict, res = verdict_test_file(string(file_name,"_invalid2"),0)
    #             if verdict == "KO"
    #                 return verdict
    #             end
    #         end
    #     end
        
    # end
    
    return "UNCERTAIN"
end

# ----- MUTATION SCORE -----
function mutation_score(test_set, mutants)

    killed = 0
    uncertain = 0
    m_t = []
    u_t = []
        
    for i in mutants
        l_verdicts = ""
        for j in test_set
            if (typeof(j) == DataTest)
                verdict = test_eval(i, j,"mutation_score")
                l_verdicts = l_verdicts * verdict * ","
            end
        end
        
        if occursin("KO",l_verdicts)
            killed += 1
        elseif occursin("UNCERTAIN",l_verdicts)
            uncertain += 1
        end
    end

    return killed, uncertain
   
end


# ----- MAIN ALGORITHM -----
function magneto(constraint::DataConstraint, mutants)

    test_set = 0
    # Generate first test for the first mutant
    for i in mutants
        test_set = gen_test(constraint,i)
        if test_set != nothing
            test_set = [test_set]
            break
        else
            test_set = 0
        end
    end

    if test_set == 0
        return [],mutants
    end

    score_k, score_u = mutation_score(test_set,mutants)
    
    # Evaluate mutants on test set. If mutant not killed, generate a new test
    for j in mutants
        # Apply whole test set on each mutant
        mutant_verdict = ""
        ct = 0
        for i in test_set
            ct += 1
	    verdict = test_eval(j,i,"Magneto_evaluation")
            mutant_verdict= mutant_verdict * verdict * ","
        end

        # If all the tests have failed, then generate a new test to kill the mutant
        if (!occursin("KO",mutant_verdict)) #&& (!occursin("UN",mutant_verdict))
            # Generate new test
            new_test = gen_test(constraint,j)
            if (new_test != nothing)
                new_test_set=deepcopy(test_set)
                push!(new_test_set,new_test)
                score_k_new, score_u_new = mutation_score(new_test_set,mutants)
                if(score_k_new > score_k)
                    score_k = score_k_new
                    push!(test_set,new_test)
                end
            end
        end
    end
    return test_set
end


end

