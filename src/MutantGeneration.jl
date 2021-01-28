# MutantGeneration.jl
module MutantGeneration

using IntervalArithmetic
using DataStructure
using PrintConstraint

# ----- EXPORT FUNCTIONS -----
export mutants_generation
export mutants_generation_1mutation


# ----- PRECISION MUTANTS GENERATION -----
function precision_mutant(constraint::DataConstraint,new_value::BigFloat)
    # Create new mutant
    new_mutant = deepcopy(constraint)
    # Mutate RelativeError value
    new_mutant.dataRelativeError.dataValue = new_value
    return new_mutant    
end

function precision_mutants_generation(constraint::DataConstraint)
    
    mutants = []
    # Loop on the possible values for relative error (between [10^-12,1[
    for i = 1:_MIN_REL_ERR
        # New relative error inrease
        new_rel_err = big(10^i) * big(constraint.dataRelativeError.dataValue)
        if ( new_rel_err < 1)
            # Compute and save new mutant
            new_mutant = precision_mutant(constraint,new_rel_err)
            # Set mutant name
            new_mutant.dataName = string(constraint.dataName,"_precision_",i)
            mutants = append!(mutants,[new_mutant])
        end
    end
    return mutants        
end

# ----- BOUNDS MUTANTS GENERATION -----
function bounds_mutant(constraint::DataConstraint,new_var_lo::DataVariable,new_var_hi::DataVariable,i::Int64)
    # Create new mutants
    new_mutant_lo = deepcopy(constraint)
    new_mutant_hi = deepcopy(constraint)
    
    # Mutate values of new_var
    new_mutant_lo.dataVariables[i].dataName = string(new_var_lo.dataName,"_m")
    new_mutant_lo.dataVariables[i].dataValue = new_var_lo.dataValue
    new_mutant_lo.dataName = string(constraint.dataName,"_bounds_low_",i)
    new_mutant_hi.dataVariables[i].dataName = string(new_var_hi.dataName,"_m") 
    new_mutant_hi.dataVariables[i].dataValue = new_var_hi.dataValue
    new_mutant_hi.dataName = string(constraint.dataName,"_bounds_high_",i)
    
    return [new_mutant_lo, new_mutant_hi]    
end

function bounds_mutants_generation(constraint::DataConstraint)
    mutants = []
    # Loop on the possible variables to mutate
    for i = 2:length(constraint.dataVariables)
        # New low value
        lo = min(constraint.dataVariables[i].dataValue.lo * (1 + 10^(-1)),constraint.dataVariables[i].dataValue.lo * (1 - 10^(-1)))
        # New high value
        hi = max(constraint.dataVariables[i].dataValue.hi * (1 + 10^(-1)),constraint.dataVariables[i].dataValue.hi * (1 - 10^(-1)))
        # Compute mutants
        new_var_lo = deepcopy(constraint.dataVariables[i])
        new_var_lo.dataValue = @interval(lo,constraint.dataVariables[i].dataValue.hi)
        new_var_hi = deepcopy(constraint.dataVariables[i])
        new_var_hi.dataValue = @interval(constraint.dataVariables[i].dataValue.lo,hi)
        new_mutants = bounds_mutant(constraint,new_var_lo,new_var_hi,i)
        mutants = append!(mutants,new_mutants)
    end
    return mutants        
end

# ----- CONSTANT MUTANTS GENERATION -----
function constant_mutant(constraint::DataConstraint,new_cst_lo::DataConstant,new_cst_hi::DataConstant,i::Int64)
    # Create new mutants
    new_mutant_lo = deepcopy(constraint)
    new_mutant_hi = deepcopy(constraint)
    
    # Mutate values of new_cst
    new_mutant_lo.dataConstants[i].dataName = string(new_cst_lo.dataName,"_m")
    new_mutant_lo.dataConstants[i].dataValue = new_cst_lo.dataValue
    new_mutant_lo.dataName = string(constraint.dataName,"_constant_low_",i)
    new_mutant_hi.dataConstants[i].dataName = string(new_cst_hi.dataName,"_m") 
    new_mutant_hi.dataConstants[i].dataValue = new_cst_hi.dataValue
    new_mutant_hi.dataName = string(constraint.dataName,"_constant_high_",i)

    return [new_mutant_lo, new_mutant_hi]    
end

function constant_mutants_generation(constraint::DataConstraint)
    mutants = []
    # Loop on the possible constants to mutate
    for i = 1:length(constraint.dataConstants)
        # Mutation depend on the type of the contant
        if (constraint.dataConstants[i].dataType == "int")
            # New low value
            lo = min(constraint.dataConstants[i].dataValue + 1,constraint.dataConstants[i].dataValue - 1)
            # New high value
            hi = max(constraint.dataConstants[i].dataValue + 1,constraint.dataConstants[i].dataValue - 1)
        else
            # New low value
            lo = min(constraint.dataConstants[i].dataValue * (1 + 10*constraint.dataRelativeError.dataValue),constraint.dataConstants[i].dataValue * (1 - 10*constraint.dataRelativeError.dataValue))
            # New high value
            hi = max(constraint.dataConstants[i].dataValue * (1 + 10*constraint.dataRelativeError.dataValue),constraint.dataConstants[i].dataValue * (1 - 10*constraint.dataRelativeError.dataValue))
        end
        # Compute mutants
        new_cst_lo = deepcopy(constraint.dataConstants[i])
        new_cst_lo.dataValue = lo
        new_cst_hi = deepcopy(constraint.dataConstants[i])
        new_cst_hi.dataValue = hi
        new_mutants = constant_mutant(constraint,new_cst_lo,new_cst_hi,i)
        mutants = append!(mutants,new_mutants)
    end
    return mutants        
end

# ----- VARIABLE MUTANTS GENERATION -----
function variable_mutant(constraint::DataConstraint,data::Data,v_eq::DataVariable)
    if (typeof(data) == DataConstant)
        return -1
    elseif (typeof(data) == DataVariable)
        mutants = []
        for i = 1:length(constraint.dataVariables)
            if (constraint.dataVariables[i].dataName != data.dataName) && (constraint.dataVariables[i].dataName != "y") && (constraint.dataVariables[i].dataName != v_eq.dataName)
                # copy mutant with new variable
                new_mutant_var = deepcopy(constraint.dataVariables[i])
                mutants = append!(mutants,[new_mutant_var])
            end
        end
        return mutants
    elseif (typeof(data) == DataUnaryOperation)
        # recursive call
        v_eq.dataName="null"
        var = variable_mutant(constraint,data.dataOperand,v_eq)
        if (var == -1)
            return -1
        else
            mutants = []
            for v in var
                new_mutant = deepcopy(data)
                new_mutant.dataOperand=v
                mutants = append!(mutants,[new_mutant])
            end
            return mutants
        end
    else
        # Check for equivalent mutants, commutativity
        if (((data.dataSymbol == "+") || (data.dataSymbol == "*")) && ((typeof(data.dataLeftOperand) == DataVariable) && (typeof(data.dataRightOperand) == DataVariable)))
            # recursive call
            v_eq = data.dataRightOperand
            var_l = variable_mutant(constraint,data.dataLeftOperand,v_eq)
            v_eq = data.dataLeftOperand
            var_r = variable_mutant(constraint,data.dataRightOperand,v_eq)
        else
            # recursive call
            v_eq.dataName="null"
            var_l = variable_mutant(constraint,data.dataLeftOperand,v_eq)
            var_r = variable_mutant(constraint,data.dataRightOperand,v_eq)
        end
        if (var_l == -1) && (var_r == -1)
            return -1
        else
            mutants = []
            if (var_l != -1)
                for v in var_l
                    new_mutant = deepcopy(data)
                    new_mutant.dataLeftOperand=v
                    mutants = append!(mutants,[new_mutant])
                end
            end
            if (var_r != -1)
                for v in var_r
                    new_mutant = deepcopy(data)
                    new_mutant.dataRightOperand=v
                    mutants = append!(mutants,[new_mutant])
                end
            end
            return mutants
        end
    end
end

function variable_mutants_generation(constraint::DataConstraint)
    mutants = []

    # Mutate Right operand
    op_r = variable_mutant(constraint,constraint.dataRight,DataVariable("null","real",@interval(-Inf,+Inf)))

    # Construct mutant constraints
    for i = 1:length(op_r)
        if op_r[i] != -1
            new_mutant = deepcopy(constraint)
            new_mutant.dataRight = op_r[i]
            new_mutant.dataName = string(new_mutant.dataName,"_variable_",i)
            mutants = append!(mutants,[new_mutant])
        end
    end
    
    return mutants        
end

# ----- UNARY MUTANTS GENERATION -----
function unary_mutant(constraint::DataConstraint,data::Data)
    if (typeof(data) == DataConstant)
        return -1
    elseif (typeof(data) == DataVariable)
        return -1
    elseif (typeof(data) == DataUnaryOperation)
        # recursive call
        var = unary_mutant(constraint,data.dataOperand)
        mutants = []
        if (var != -1 )
            # Mutation happened deeper in the constraint
            for v in var
                new_mutant = deepcopy(data)
                new_mutant.dataOperand=v
                mutants = append!(mutants,[new_mutant])
            end
        end
        # Apply mutation
        for i in dataUnaryOperationSymbols 
            if (data.dataSymbol != i)
                # copy mutant with new variable
                new_op = deepcopy(data)
                new_op.dataSymbol = i
                mutants = append!(mutants,[new_op])
            end
        end
        return mutants
    else
        # recursive call
        var_l = unary_mutant(constraint,data.dataLeftOperand)
        var_r = unary_mutant(constraint,data.dataRightOperand)
        if (var_l == -1) && (var_r == -1)
            return -1
        else
            mutants = []
            if (var_l != -1)
                for v in var_l
                    new_mutant = deepcopy(data)
                    new_mutant.dataLeftOperand=v
                    mutants = append!(mutants,[new_mutant])
                end
            end
            if (var_r != -1)
                for v in var_r
                    new_mutant = deepcopy(data)
                    new_mutant.dataRightOperand=v
                    mutants = append!(mutants,[new_mutant])
                end
            end
            return mutants
        end
    end
end

function unary_mutants_generation(constraint::DataConstraint)
    mutants = []

    # Mutate Right operand
    op_r = unary_mutant(constraint,constraint.dataRight)

    for i = 1:length(op_r)
        if op_r[i] != -1
            new_mutant = deepcopy(constraint)
            new_mutant.dataRight = op_r[i]
            new_mutant.dataName = string(new_mutant.dataName,"_unary_",i)
            mutants = append!(mutants,[new_mutant])
        end
    end
    
    return mutants        
end

# ----- BINARY MUTANTS GENERATION -----
function binary_mutant(constraint::DataConstraint,data::Data)
    if (typeof(data) == DataConstant)
        return -1
    elseif (typeof(data) == DataVariable)
        return -1
    elseif (typeof(data) == DataUnaryOperation)
        # recursive call
        var = binary_mutant(constraint,data.dataOperand)
        if (var == -1)
            return -1
        else
            mutants = []
            for v in var
                new_mutant = deepcopy(data)
                new_mutant.dataOperand=v
                mutants = append!(mutants,[new_mutant])
            end
            return mutants
        end
    else
        # recursive call
        var_l = binary_mutant(constraint,data.dataLeftOperand)
        var_r = binary_mutant(constraint,data.dataRightOperand)
        mutants = []
        if (var_l != -1)
            # Mutation happened deeper in the constraint
            for v in var_l
                new_mutant = deepcopy(data)
                new_mutant.dataLeftOperand=v
                mutants = append!(mutants,[new_mutant])
            end
        end
        if (var_r != -1)
            # Mutation happened deeper in the constraint
            for v in var_r
                new_mutant = deepcopy(data)
                new_mutant.dataRightOperand=v
                mutants = append!(mutants,[new_mutant])
            end
        end
        # Apply mutation
        for i in dataBinaryOperationSymbols 
            if (data.dataSymbol != i)
                if (i == "^")
                    if (typeof(var_r) == DataConstant)
                        # copy mutant with new variable
                        new_op = deepcopy(data)
                        new_op.dataSymbol = i
                        mutants = append!(mutants,[new_op])
                    end
                else
                    # copy mutant with new variable
                    new_op = deepcopy(data)
                    new_op.dataSymbol = i
                    mutants = append!(mutants,[new_op])
                end
            end
        end
        return mutants
    end
end

function binary_mutants_generation(constraint::DataConstraint)
    mutants = []

    # Mutate Right operand
    op_r = binary_mutant(constraint,constraint.dataRight)

    for i = 1:length(op_r)
        if op_r[i] != -1
            new_mutant = deepcopy(constraint)
            new_mutant.dataRight = op_r[i]
            new_mutant.dataName = string(new_mutant.dataName,"_binary_",i)
            mutants = append!(mutants,[new_mutant])
        end
    end
    
    return mutants        
end

# ----- ADD MUTANTS GENERATION -----
function add_mutant(constraint::DataConstraint,data::Data)
    if (typeof(data) == DataConstant)
        return -1
    elseif (typeof(data) == DataVariable)
        # New Binary Operation
        mutants = []
        for i in dataBinaryOperationSymbols 
            if (i != "^")
                new_op = DataBinaryOperation(i,data,data)
                mutants = append!(mutants,[new_op])
            end
        end
        # New Unary Operation
        for i in dataUnaryOperationSymbols 
            new_op = DataUnaryOperation(i,data)
            mutants = append!(mutants,[new_op])
        end
        return mutants
    elseif (typeof(data) == DataUnaryOperation)
        # recursive call
        var = add_mutant(constraint,data.dataOperand)
        if (var == -1)
            return -1
        else
            mutants = []
            for v in var
                new_mutant = deepcopy(data)
                new_mutant.dataOperand=v
                mutants = append!(mutants,[new_mutant])
            end
            return mutants
        end
    else
        # recursive call
        var_l = add_mutant(constraint,data.dataLeftOperand)
        var_r = add_mutant(constraint,data.dataRightOperand)
        mutants = []
        if (var_l == -1) && (var_r == -1)
            return -1
        else
            if (var_l != -1)
                # Mutation happened deeper in the constraint
                for v in var_l
                    new_mutant = deepcopy(data)
                    new_mutant.dataLeftOperand=v
                    mutants = append!(mutants,[new_mutant])
                end
            end
            if (var_r != -1)
                # Mutation happened deeper in the constraint
                for v in var_r
                    new_mutant = deepcopy(data)
                    new_mutant.dataRightOperand=v
                    mutants = append!(mutants,[new_mutant])
                end
            end
            return mutants
        end
    end
end

function add_mutants_generation(constraint::DataConstraint)
    mutants = []

    # Mutate Right operand
    op_r = add_mutant(constraint,constraint.dataRight)

    for i = 1:length(op_r)
        new_mutant = deepcopy(constraint)
        new_mutant.dataRight = op_r[i]
        new_mutant.dataName = string(new_mutant.dataName,"_add_right_",i)
        mutants = append!(mutants,[new_mutant])
    end
    
    return mutants        
end

# ----- DEL MUTANTS GENERATION -----
function del_mutant(constraint::DataConstraint,data::Data)
    if (typeof(data) == DataConstant)
        return -1
    elseif (typeof(data) == DataVariable)
        return -1
    elseif (typeof(data) == DataUnaryOperation)
        # recursive call
        var = del_mutant(constraint,data.dataOperand)
        mutants = []
        if (var == -1)
            return -2
        elseif (var == -2)
            for i = 2:length(constraint.dataVariables)
                new_mutant = deepcopy(constraint.dataVariables[i])
                mutants = append!(mutants,[new_mutant])
            end
            return mutants
        else
            # Mutation happened deeper in the constraint
            for v in var
                new_mutant = deepcopy(data)
                new_mutant.dataOperand=v
                mutants = append!(mutants,[new_mutant])
            end
            return mutants
        end
    else
        # recursive call
        var_l = del_mutant(constraint,data.dataLeftOperand)
        var_r = del_mutant(constraint,data.dataRightOperand)
        mutants = []
        if (var_l == -1) && (var_r == -1)
            return -2
        else
            if (var_l == -2) || (var_r == -2)
                for i = 2:length(constraint.dataVariables)
                    new_mutant = deepcopy(constraint.dataVariables[i])
                    mutants = append!(mutants,[new_mutant])
                end
                return mutants
            end
            if (var_l != -1)
            # Mutation happened deeper in the constraint
                for v in var_l
                    new_mutant = deepcopy(data)
                    new_mutant.dataLeftOperand=v
                    mutants = append!(mutants,[new_mutant])
                end
            end
            if (var_r != -1)
                # Mutation happened deeper in the constraint
                for v in var_r
                    new_mutant = deepcopy(data)
                    new_mutant.dataRightOperand=v
                    mutants = append!(mutants,[new_mutant])
                end
            end
            return mutants
        end
    end
end

function del_mutants_generation(constraint::DataConstraint)
    mutants = []

    # Mutate Right operand
    op_r = del_mutant(constraint,constraint.dataRight)

    for i = 1:length(op_r)
        new_mutant = deepcopy(constraint)
        new_mutant.dataRight = op_r[i]
        new_mutant.dataName = string(new_mutant.dataName,"_del_right_",i)
        mutants = append!(mutants,[new_mutant])
    end
    
    return mutants        
end


# ----- MUTANTS GENERATION -----
function mutants_generation(constraint::DataConstraint)

    mutants = constant_mutants_generation(constraint)
    new_mutants = bounds_mutants_generation(constraint)
    mutants = append!(mutants,new_mutants)
    new_mutants = variable_mutants_generation(constraint)
    mutants = append!(mutants,new_mutants)
    new_mutants = unary_mutants_generation(constraint)
    mutants = append!(mutants,new_mutants)
    new_mutants = binary_mutants_generation(constraint)
    mutants = append!(mutants,new_mutants)
    new_mutants = precision_mutants_generation(constraint)
    mutants = append!(mutants,new_mutants)
    new_mutants = add_mutants_generation(constraint)
    mutants = append!(mutants,new_mutants)
    new_mutants = del_mutants_generation(constraint)
    mutants = append!(mutants,new_mutants)
    
   return mutants
end

# ----- MUTANTS GENERATION -----
function mutants_generation_1mutation(constraint::DataConstraint,mutation_name)

    if (mutation_name == "precision")
        return precision_mutants_generation(constraint)
    end
    if (mutation_name == "bounds")
        return bounds_mutants_generation(constraint)
    end
    if (mutation_name == "constant")
        return constant_mutants_generation(constraint)
    end
    if (mutation_name == "variable")
        return variable_mutants_generation(constraint)
    end
    if (mutation_name == "unary")
        return unary_mutants_generation(constraint)
    end
    if (mutation_name == "binary")
        return binary_mutants_generation(constraint)
    end
    if (mutation_name == "add")
        return add_mutants_generation(constraint)
    end
    if (mutation_name == "del")
        return del_mutants_generation(constraint)
    end
end


end

