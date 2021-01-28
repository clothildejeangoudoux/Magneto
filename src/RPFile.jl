# RPFile.jl
module RPFile

using IntervalArithmetic
using DataStructure
using PrintConstraint
using TestFunctions

# ----- EXPORT FUNCTIONS -----
export gen_RPFile_test_evaluation
export gen_RPFile_test_generation
export parse_RP_result_pick_input_test
export verdict_test_file

# ----- GENERATE NEW RP FILE FOR TEST EVALUATION -----
function gen_RPFile_test_evaluation_h(constraint::DataConstraint,test_variables::DataTest,abs_precision::Float64,file_name,test_type)
    f = open(string(file_name),"w")
   
    # Write in file:
    # Branch precision, number and time
    println(f,"Branch precision = ",abs_precision,",")
    println(f,"number = ",_NB_BOXES,";\n")
    println(f,"Time = ",_TIME,";\n")
    
    # Constants (when exists)
    println(f,"Constants")
    for i in constraint.dataConstants
        println(f,i.dataName," = ",Float64(i.dataValue),",")
    end
    for i = 1:length(test_variables.dataTestVariables)
        if constraint.dataVariables[i+1].dataName == string(test_variables.dataTestVariables[i].dataName,"_m")
            println(f,string(constraint.dataVariables[i+1].dataName)," = ",Float64(test_variables.dataTestVariables[i].dataValue),",")
        else
            println(f,test_variables.dataTestVariables[i].dataName," = ",Float64(test_variables.dataTestVariables[i].dataValue),",")
        end
    end
    println(f,"eps = ",Float64(constraint.dataRelativeError.dataValue),";\n")
    
    # Variables with fixed values
    println(f,"Variables")
    # Create & Open file
    if test_type == 1
        if (isinf(test_variables.dataTestResult.dataValid[1].lo))
            print(f,"y in ]-oo")
        else
            print(f,"y in ]",Float64(test_variables.dataTestResult.dataValid[1].lo))
        end
        if (isinf(test_variables.dataTestResult.dataValid[1].hi))
            println(f,", +oo [;\n")
        else
            println(f,",",Float64(test_variables.dataTestResult.dataValid[1].hi),"[;\n")
        end
    end
    if test_type == 2
        if (isinf(test_variables.dataTestResult.dataInvalid[1].lo))
            print(f,"y in ]-oo")
        else
            print(f,"y in ]",Float64(test_variables.dataTestResult.dataInvalid[1].lo))
        end
        if (isinf(test_variables.dataTestResult.dataInvalid[1].hi))
            println(f,", +oo [;\n")
        else
            println(f,",",Float64(test_variables.dataTestResult.dataInvalid[1].hi),"[;\n") 
        end
    end
    if test_type == 3
        if (isinf(test_variables.dataTestResult.dataInvalid[2].lo))
            print(f,"y in ]-oo")
        else
            print(f,"y in ]",Float64(test_variables.dataTestResult.dataInvalid[2].lo))
        end
        if (isinf(test_variables.dataTestResult.dataInvalid[2].hi))
            println(f,", +oo [;\n")
        else
            println(f,",",Float64(test_variables.dataTestResult.dataInvalid[2].hi,"[;\n"))
        end
    end


    
    # Constraints (recursive call)
    println(f,"Constraints")
    tree = gen_csp_tree(constraint.dataRight)
    if (constraint.dataSymbol == "=")
        println(f,"y <= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree,")*(1+eps), (",tree,")*(1-eps));")
    elseif (constraint.dataSymbol == "<=")
        println(f,"y <= max((",tree,")*(1+eps), (",tree,")*(1-eps));")
    else
        println(f,"y >= min((",tree,")*(1+eps), (",tree,")*(1-eps));")          
    end
    
    # Close File
    close(f)
end

# ----- GENERATE NEW RP FILE FOR TEST EVALUATION -----
function gen_RPFile_test_evaluation(constraint::DataConstraint,test_variables::DataTest,abs_precision::Float64,file_name)
    # Create & Open file
    if test_variables.dataTestResult.dataValid != nothing
        fn = string(file_name,"_valid")
        gen_RPFile_test_evaluation_h(constraint,test_variables,abs_precision,fn,1)
    end
    if test_variables.dataTestResult.dataInvalid[1] != nothing
        fn = string(file_name,"_invalid1")
        gen_RPFile_test_evaluation_h(constraint,test_variables,abs_precision,fn,2)
    end
    if test_variables.dataTestResult.dataInvalid[2] != nothing
        fn = string(file_name,"_invalid2")
        gen_RPFile_test_evaluation_h(constraint,test_variables,abs_precision,fn,3)
    end
end



# ----- PARSE RP OUTPUT FOR TEST GENERATION, RETURNS TABLE OF VARIABLES -----
function parse_RP_result_pick_input_test(rp_out,constraint::DataConstraint,mutant::DataConstraint,file_name)
    
    tbl_variables = []
    for i = 1:length(constraint.dataVariables)-1
        var = deepcopy(constraint.dataVariables[i+1])
        tbl_variables = append!(tbl_variables,[var])
    end

    for i = 1:length(tbl_variables)
        if (occursin("INNER BOX",rp_out))
            index=findfirst("INNER BOX",rp_out)
            index_c=findnext(string(tbl_variables[i].dataName," "),rp_out,index.stop)
            
            # pick value for i
            ind1 = findnext('[',rp_out,index_c.stop)
            ind2 = findnext(',',rp_out,index_c.stop)
            ind3 = findnext('=',rp_out,index_c.stop)
            ind4 = findnext('\n',rp_out,index_c.stop)
            if (ind1 != nothing)
                if (ind3 != nothing)
                    if (ind3 < ind1)
                        low = BigFloat(rp_out[ind3+1:ind4-1])
                        high = low
                    else
                        low = BigFloat(rp_out[ind1+1:ind2-1])
                        ind1 = findnext(']',rp_out,index_c.stop)
                        high = BigFloat(rp_out[ind2+1:ind1-1])
                    end
                else
                    low = BigFloat(rp_out[ind1+1:ind2-1])
                    ind1 = findnext(']',rp_out,index_c.stop)
                    high = BigFloat(rp_out[ind2+1:ind1-1])
                end
            else
                low = BigFloat(rp_out[ind3+1:ind4-1])
                high = low 
            end
                
            if (string(tbl_variables[i].dataName,"_m") == mutant.dataVariables[i+1].dataName)
                index_m=findnext(mutant.dataVariables[i+1].dataName,rp_out,index.stop)

                ind1_m = findnext('[',rp_out,index_m.stop)
                ind2_m = findnext(',',rp_out,index_m.stop)
                ind3_m = findnext('=',rp_out,index_m.stop)
                ind4_m = findnext('\n',rp_out,index_m.stop)
                if (ind1 != nothing)
                    if (ind3 != nothing)
                        if (ind3 < ind1)
                            low_m = BigFloat(rp_out[ind3_m+1:ind4_m-1])
                            high_m = low_m
                        else
                            low_m = BigFloat(rp_out[ind1_m+1:ind2_m-1])
                            ind1_m = findnext(']',rp_out,index_m.stop)
                            high_m = BigFloat(rp_out[ind2_m+1:ind1_m-1])
                        end
                    else
                        low_m = BigFloat(rp_out[ind1_m+1:ind2_m-1])
                        ind1_m = findnext(']',rp_out,index_m.stop)
                        high_m = BigFloat(rp_out[ind2_m+1:ind1_m-1])
                    end
                else
                    low_m = BigFloat(rp_out[ind3_m+1:ind4_m-1])
                    high_m = low_m
                end
                                
                if (low < low_m)
                    mid = low + (low_m - low) / 2
                elseif (low > low_m)
                    mid = low_m + (low - low_m) / 2
                elseif (high > high_m)
                    mid = high - (high - high_m) / 2
                elseif (high < high_m)
                    mid = high_m - (high_m - high) / 2
                else
                    mid = (low+high)/2
                end
            else
                # mid = (low+high)/2
                mid = low + (rand(Float64,1)[1] * (high - low + 1))
            end
            tbl_variables[i].dataValue = mid
           
        end        
    end
    
    return tbl_variables
end

# ----- PRECISION RP FILE FOR TEST GENERATION -----
function gen_RPFile_precision_test_generation(constraint::DataConstraint,mutant::DataConstraint,abs_precision::Float64,file_name)
    # Create & Open file
    f = open(file_name,"w")

    # Write in file:
    # Branch precision, number and time 
    println(f,"Branch precision = ",abs_precision,",")
    println(f,"number = ",_NB_BOXES,";\n")
    println(f,"Time = ",_TIME,";\n")

    # Constants
    println(f,"Constants")
    for i in constraint.dataConstants
        println(f,i.dataName," = ",Float64(i.dataValue),",")
    end
    println(f,"eps = ",Float64(constraint.dataRelativeError.dataValue),",")
    println(f,"eps_m = ",Float64(mutant.dataRelativeError.dataValue),";\n")
    
    # Variables with fixed values
    println(f,"Variables")
    if (isinf(constraint.dataVariables[1].dataValue.lo))
        println(f,"y in ]-oo, +oo[,")
    else
        println(f,"y in [",Float64(constraint.dataVariables[1].dataValue.lo),", ",Float64(constraint.dataVariables[1].dataValue.hi),"],")
    end
    max = length(constraint.dataVariables)
    for i in 2:max-1
        println(f,constraint.dataVariables[i].dataName," in [",Float64(constraint.dataVariables[i].dataValue.lo),", ",Float64(constraint.dataVariables[i].dataValue.hi),"],\n")
    end
    println(f,constraint.dataVariables[max].dataName," in [",Float64(constraint.dataVariables[max].dataValue.lo),", ",Float64(constraint.dataVariables[max].dataValue.hi),"];\n")
    
    # Constraints (recursive call)
    println(f,"Constraints")
    tree = gen_csp_tree(constraint.dataRight)
    if occursin("min",constraint.dataName)
        println(f,"y <= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree,")*(1+eps_m), (",tree,")*(1-eps_m));")
    end
    if occursin("max",constraint.dataName)
        println(f,"y >= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y <= max((",tree,")*(1+eps_m), (",tree,")*(1-eps_m));")
    end
    
    # Close File
    close(f)
end

# ----- BOUNDS RP FILE FOR TEST GENERATION -----
function gen_RPFile_bounds_test_generation(constraint::DataConstraint,mutant::DataConstraint,abs_precision::Float64,file_name)
    # Create & Open file
    f = open(file_name,"w")

    # Write in file:
    # Branch precision, number and time 
    println(f,"Branch precision = ",abs_precision,",")
    println(f,"number = ",_NB_BOXES,";\n")
    println(f,"Time = ",_TIME,";\n")
    
    # Constants
    println(f,"Constants")
    for i in constraint.dataConstants
        println(f,i.dataName," = ",Float64(i.dataValue),",")
    end
    println(f,"eps = ",Float64(constraint.dataRelativeError.dataValue),";\n")
    
    # Variables with fixed values
    println(f,"Variables")
    if (isinf(constraint.dataVariables[1].dataValue.lo))
        println(f,"y in ]-oo, +oo[,")
    else
        println(f,"y in [",Float64(constraint.dataVariables[1].dataValue.lo),", ",Float64(constraint.dataVariables[1].dataValue.hi),"],")
    end
    maxi = length(constraint.dataVariables)
    for i in 2:maxi-1
        if (constraint.dataVariables[i].dataName != mutant.dataVariables[i].dataName)
            println(f,mutant.dataVariables[i].dataName," in [",Float64(mutant.dataVariables[i].dataValue.lo),", ",Float64(mutant.dataVariables[i].dataValue.hi),"],")
            println(f,constraint.dataVariables[i].dataName," in [",Float64(constraint.dataVariables[i].dataValue.lo),", ",Float64(constraint.dataVariables[i].dataValue.hi),"],")
        else
            println(f,constraint.dataVariables[i].dataName," in [",Float64(constraint.dataVariables[i].dataValue.lo),", ",Float64(constraint.dataVariables[i].dataValue.hi),"],")
        end
    end
    if (constraint.dataVariables[maxi].dataName != mutant.dataVariables[maxi].dataName)
        println(f,mutant.dataVariables[maxi].dataName," in [",Float64(mutant.dataVariables[maxi].dataValue.lo),", ",Float64(mutant.dataVariables[maxi].dataValue.hi),"],")
        println(f,constraint.dataVariables[maxi].dataName," in [",Float64(constraint.dataVariables[maxi].dataValue.lo),", ",Float64(constraint.dataVariables[maxi].dataValue.hi),"];\n")
    else
        println(f,constraint.dataVariables[maxi].dataName," in [",Float64(constraint.dataVariables[maxi].dataValue.lo),", ",Float64(constraint.dataVariables[maxi].dataValue.hi),"];\n")
    end
    
    # Constraints (recursive call)
    println(f,"Constraints")
    tree = gen_csp_tree(constraint.dataRight)
    tree_m = gen_csp_tree(mutant.dataRight)
    if occursin("min_out",constraint.dataName)
        println(f,"y <= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    elseif occursin("max_out",constraint.dataName)
        println(f,"y >= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y <= max((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    elseif occursin("min_in",constraint.dataName)
        println(f,"y <= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= max((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    else
        println(f,"y <= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y <= min((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    end

    # Close File
    close(f)
end

# ----- CONSTANT RP FILE FOR TEST GENERATION -----
function gen_RPFile_constant_test_generation(constraint::DataConstraint,mutant::DataConstraint,abs_precision::Float64,file_name)
    # Create & Open file
    f = open(file_name,"w")

    # Write in file:
    # Branch precision, number and time 
    println(f,"Branch precision = ",abs_precision,",")
    println(f,"number = ",_NB_BOXES,";\n")
    println(f,"Time = ",_TIME,";\n")
    
    # Constants
    println(f,"Constants")
    for i =1:length(constraint.dataConstants)
        if (constraint.dataConstants[i].dataName != mutant.dataConstants[i].dataName)
            println(f,mutant.dataConstants[i].dataName," = ",Float64(mutant.dataConstants[i].dataValue),",")
        end
        println(f,constraint.dataConstants[i].dataName," = ",Float64(constraint.dataConstants[i].dataValue),",")
    end
    println(f,"eps = ",Float64(constraint.dataRelativeError.dataValue),";\n")
    
    # Variables with fixed values
    println(f,"Variables")
    if (isinf(constraint.dataVariables[1].dataValue.lo))
        println(f,"y in ]-oo, +oo[,")
    else
        println(f,"y in [",Float64(constraint.dataVariables[1].dataValue.lo),", ",Float64(constraint.dataVariables[1].dataValue.hi),"],")
    end
    max = length(constraint.dataVariables)
    for i in 2:max-1
        println(f,constraint.dataVariables[i].dataName," in [",Float64(constraint.dataVariables[i].dataValue.lo),", ",Float64(constraint.dataVariables[i].dataValue.hi),"],")
    end
    println(f,constraint.dataVariables[max].dataName," in [",Float64(constraint.dataVariables[max].dataValue.lo),", ",Float64(constraint.dataVariables[max].dataValue.hi),"];\n")
    
    # Constraints (recursive call)
    println(f,"Constraints")
    tree = gen_csp_tree(constraint.dataRight)
    tree_m = gen_csp_tree(mutant.dataRight)
    if occursin("min_out",constraint.dataName)
        println(f,"y <= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    elseif occursin("max_out",constraint.dataName)
        println(f,"y >= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y <= max((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    elseif occursin("min_in",constraint.dataName)
        println(f,"y <= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= max((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    else
        println(f,"y <= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y <= min((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    end
    
    # Close File
    close(f)
end

# ----- OTHER RP FILE FOR TEST GENERATION -----
function gen_RPFile_variable_test_generation(constraint::DataConstraint,mutant::DataConstraint,abs_precision::Float64,file_name)
    # Create & Open file
    f = open(file_name,"w")

    # Write in file:
    # Branch precision, number and time 
    println(f,"Branch precision = ",abs_precision,",")
    println(f,"number = ",_NB_BOXES,";\n")
    println(f,"Time = ",_TIME,";\n")
    
    # Constants
    println(f,"Constants")
    for i in constraint.dataConstants
        println(f,i.dataName," = ",Float64(i.dataValue),",")
    end
    println(f,"eps = ",Float64(constraint.dataRelativeError.dataValue),";\n")
    
    # Variables with fixed values
    println(f,"Variables")
    if (isinf(constraint.dataVariables[1].dataValue.lo))
        println(f,"y in ]-oo, +oo[,")
    else
        println(f,"y in [",Float64(constraint.dataVariables[1].dataValue.lo),", ",Float64(constraint.dataVariables[1].dataValue.hi),"],")
    end
    max = length(constraint.dataVariables)
    for i in 2:max-1
        println(f,constraint.dataVariables[i].dataName," in [",Float64(constraint.dataVariables[i].dataValue.lo),", ",Float64(constraint.dataVariables[i].dataValue.hi),"],")
    end
    println(f,constraint.dataVariables[max].dataName," in [",Float64(constraint.dataVariables[max].dataValue.lo),", ",Float64(constraint.dataVariables[max].dataValue.hi),"];\n")
    
    # Constraints (recursive call)
    println(f,"Constraints")
    tree = gen_csp_tree(constraint.dataRight)
    tree_m = gen_csp_tree(mutant.dataRight)
    if occursin("min_out",constraint.dataName)
        println(f,"y <= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    elseif occursin("max_out",constraint.dataName)
        println(f,"y >= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y <= max((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    elseif occursin("min_in",constraint.dataName)
        println(f,"y <= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= max((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    else
        println(f,"y <= max((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y >= min((",tree,")*(1+eps), (",tree,")*(1-eps)),")
        println(f,"y <= min((",tree_m,")*(1+eps), (",tree_m,")*(1-eps));")
    end
   
    # Close File
    close(f)
end

# ----- GENERATE NEW RP FILE FOR TEST GENERATION -----
function gen_RPFile_test_generation(constraint::DataConstraint,mutant::DataConstraint,abs_precision::Float64,file_name)

    if occursin("precision",file_name)
        gen_RPFile_precision_test_generation(constraint,mutant,abs_precision,file_name)
    elseif occursin("bounds",file_name)
        gen_RPFile_bounds_test_generation(constraint,mutant,abs_precision,file_name)
    elseif occursin("constant",file_name)
        gen_RPFile_constant_test_generation(constraint,mutant,abs_precision,file_name)
    else
        gen_RPFile_variable_test_generation(constraint,mutant,abs_precision,file_name)
    end
end

# ----- VERDICT TEST WITH RP EXECUTION + RESULT OF SOLVING-----
function verdict_test_file(file_name, solution)    
    # Execute with RealPaver
    cmd = `realpaver $file_name`

    # Get the output of the command
    res = read(cmd,String)
    
    # Parse result
    if (solution == 1)
        # If there is one inner box expected
        if (occursin("INNER BOX",res))
            # There exist a y value that is solution of this test      
            return "OK", res
        else
            # There is no result
            return "KO", res
        end
    else 
        # If there is no solution expected
        # If there is one inner box expected
        if (occursin("INNER BOX",res))
            # There exist a y value that is solution of this test      
            return "KO", res
        else
            # There is no result
            return "OK", res
        end
    end
end


end

