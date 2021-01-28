# TestFunctions.jl
module TestFunctions

using IntervalArithmetic
using DataStructure
using PrintConstraint
using MutantGeneration

export pick_test
export is_test
export is_test_bound
export gen_csp_test
export gen_csp_tree
export gen_csp_tree_mutant
export count_op
export depth_tree

# ----- GENERATE CONSTRAINT AS STRING -----
function gen_csp_tree(data::Data)

    if (typeof(data)==DataConstant)
        return data.dataName
    elseif (typeof(data)==DataVariable)
        return data.dataName
    elseif (typeof(data)==DataUnaryOperation)
        return string(data.dataSymbol,"(",gen_csp_tree(data.dataOperand),")")
    else
        if ((data.dataSymbol == "min") || (data.dataSymbol == "max"))
            return string(data.dataSymbol,"(",gen_csp_tree(data.dataLeftOperand),",",gen_csp_tree(data.dataRightOperand),")")
        else
            return string("(",gen_csp_tree(data.dataLeftOperand)," ",data.dataSymbol," ",gen_csp_tree(data.dataRightOperand),")")
        end
    end
    
end

# ----- COUNT NB OPERATIONS -----
function count_op(data::Data)
    if (typeof(data)==DataConstant)
        return 0
    elseif (typeof(data)==DataVariable)
        return 0
    elseif (typeof(data)==DataUnaryOperation)
        return count_op(data.dataOperand)+1
    else
        return count_op(data.dataLeftOperand) + count_op(data.dataRightOperand) + 1
    end
end
# ----- COUNT DEPTH TREE -----
function depth_tree(data::Data)
    if (typeof(data)==DataConstant)
        return 0
    elseif (typeof(data)==DataVariable)
        return 0
    elseif (typeof(data)==DataUnaryOperation)
        return depth_tree(data.dataOperand)+1
    else
        return max(depth_tree(data.dataLeftOperand),depth_tree(data.dataRightOperand)) + 1
    end
end

# ----- GENERATE CONSTRAINT AS STRING -----
function gen_csp_tree_mutant(data::Data)

    if (typeof(data)==DataConstant)
        return data.dataName
    elseif (typeof(data)==DataVariable)
        if ((length(data.dataName) > 1) && (data.dataName[length(data.dataName)-1:length(data.dataName)] == "_m"))
            return data.dataName[1:length(data.dataName)-2]
        else
            return data.dataName
        end
    elseif (typeof(data)==DataUnaryOperation)
        return string(data.dataSymbol,"(",gen_csp_tree_mutant(data.dataOperand),")")
    else
        if ((data.dataSymbol == "min") || (data.dataSymbol == "max"))
            return string(data.dataSymbol,"(",gen_csp_tree_mutant(data.dataLeftOperand),",",gen_csp_tree_mutant(data.dataRightOperand),")")
        else
            return string("(",gen_csp_tree_mutant(data.dataLeftOperand)," ",data.dataSymbol," ",gen_csp_tree_mutant(data.dataRightOperand),")")
        end
    end
    
end


# ----- EXECUTE RP FILE AND SAVE Y INTERVAL -----
function pick_test(constraint::DataConstraint,test_variables)

    tree = gen_csp_tree(constraint.dataRight)
    tree_m = Meta.parse(string(tree,"*(1 - e)"))
    tree_p = Meta.parse(string(tree,"*(1 + e)"))

    eval(Meta.parse(string("e = @biginterval(",constraint.dataRelativeError.dataValue,")")))
    for i = 1:length(test_variables)
        if !((test_variables[i].dataValue >= constraint.dataVariables[i+1].dataValue.lo) && (test_variables[i].dataValue <= constraint.dataVariables[i+1].dataValue.hi))
            eval(Meta.parse(string(test_variables[i].dataName," = @biginterval(",constraint.dataVariables[i+1].dataValue.lo,",",constraint.dataVariables[i+1].dataValue.hi,")")))
        else
            eval(Meta.parse(string(test_variables[i].dataName," = @biginterval(",test_variables[i].dataValue,")")))
        end
    end
    for i in constraint.dataConstants
        eval(Meta.parse(string(i.dataName," = ",i.dataValue)))
    end
    bound_m = eval(tree_m)
    bound_p = eval(tree_p)
    if bound_m.hi < bound_p.lo
        # y = DataTestResult(constraint.dataVariables[1].dataName,[@biginterval(bound_m.hi,bound_p.lo)],[@biginterval(constraint.dataVariables[1].dataValue.lo,bound_m.lo),@biginterval(bound_p.hi,constraint.dataVariables[1].dataValue.hi)])
        y = DataTestResult(constraint.dataVariables[1].dataName,[@biginterval(bound_m.hi,bound_p.lo)],[@biginterval(-Inf,bound_m.lo),@biginterval(bound_p.hi,+Inf)])
    elseif bound_p.hi <bound_m.lo
        # y = DataTestResult(constraint.dataVariables[1].dataName,[@biginterval(bound_p.hi,bound_m.lo)],[@biginterval(constraint.dataVariables[1].dataValue.lo,bound_p.lo),@biginterval(bound_m.hi,constraint.dataVariables[1].dataValue.hi)])
        y = DataTestResult(constraint.dataVariables[1].dataName,[@biginterval(bound_p.hi,bound_m.lo)],[@biginterval(-Inf,bound_p.lo),@biginterval(bound_m.hi,+Inf)])
    else
        y = DataTestResult(constraint.dataVariables[1].dataName,[@biginterval(bound_m.lo,bound_p.hi)],[@biginterval(-Inf,bound_p.lo),@biginterval(bound_m.hi,+Inf)])
    end

    return y
end

# ----- IS THERE A TEST WITH RP EXECUTION + RESULT OF SOLVING -----
function is_test(file_name)    
    # Execute with RealPaver
    cmd = `timeout 3s realpaver $file_name`

    # Get the output of the command
    res = read(cmd,String)
    
    # If there is one inner box expected
    if (occursin("INNER BOX",res))
        # There exist a y value that is solution of this test      
        return "OK", res
    else
        # There is no result
        return "KO", res
    end
    
end

# ----- GENERATION OF TEST CONSTRAINTS -----
function gen_csp_test(constraint::DataConstraint,mutant::DataConstraint)    

    # Result in the form of a table of constraints c1, c2, NOT m1, NOT m2
    csp_test=[]
    
    # If constraint is PRESCISION
    # with respect the disjunction (NOT c) AND (m)
    if (occursin("precision",mutant.dataName))
        if (constraint.dataSymbol == "=") || (constraint.dataSymbol == "<=")
            c1 = deepcopy(constraint)
            m1 = deepcopy(mutant)
            
            c1.dataSymbol = ">="
            c1.dataName = string(c1.dataName,"_max")
            m1.dataSymbol = "<="
            m1.dataName = string(m1.dataName,"_max")

            csp_test = append!(csp_test,[c1,m1])
        end
        if (constraint.dataSymbol == "=") || (constraint.dataSymbol == ">=")
            c2 = deepcopy(constraint)
            m2 = deepcopy(mutant)
            
            c2.dataSymbol = "<="
            c2.dataName = string(c2.dataName,"_min")
            m2.dataSymbol = ">="
            m2.dataName = string(m2.dataName,"_min")

            csp_test = append!(csp_test,[c2,m2])
        end
        return csp_test
    end

    # If constraint is VARIABLE, CONSTANT, BOUNDS, UNARY, BINARY, ADD, DEL
    if (constraint.dataSymbol == "=") || (constraint.dataSymbol == "<=")
        c1 = deepcopy(constraint)
        m1 = deepcopy(mutant)
        
        c1.dataName = string(c1.dataName,"_max_out")
        m1.dataName = string(m1.dataName,"_max_out")
        
        csp_test = append!(csp_test,[c1,m1])

        # c3 = deepcopy(constraint)
        # m3 = deepcopy(mutant)
        
        # c3.dataName = string(c3.dataName,"_max_in")
        # m3.dataName = string(m3.dataName,"_max_in")
        
        # csp_test = append!(csp_test,[c3,m3])
    end
    if (constraint.dataSymbol == "=") || (constraint.dataSymbol == ">=")
        c2 = deepcopy(constraint)
        m2 = deepcopy(mutant)
        
        c2.dataName = string(c2.dataName,"_min_out")
        m2.dataName = string(m2.dataName,"_min_out")
        
        csp_test = append!(csp_test,[c2,m2])

        # c4 = deepcopy(constraint)
        # m4 = deepcopy(mutant)
        
        # c4.dataName = string(c4.dataName,"_min_in")
        # m4.dataName = string(m4.dataName,"_min_in")
        
        # csp_test = append!(csp_test,[c4,m4])
    end

    return csp_test
end


# ----- We don't generate RP file for BOUND mutation -----
function is_test_bound(constraint::DataConstraint,mutant::DataConstraint)

    res = "INNER BOX 00\ny in [-1, 1]\n"
    
    for i in 2:length(constraint.dataVariables)
        if (constraint.dataVariables[i].dataName != mutant.dataVariables[i].dataName)
            res = res*"$(mutant.dataVariables[i].dataName) in [ $(mutant.dataVariables[i].dataValue.lo), $(mutant.dataVariables[i].dataValue.hi)]\n"
        end
        res = res*"$(constraint.dataVariables[i].dataName) in [ $(constraint.dataVariables[i].dataValue.lo), $(constraint.dataVariables[i].dataValue.hi)]\n"
    end

    return "OK", res
end



end
