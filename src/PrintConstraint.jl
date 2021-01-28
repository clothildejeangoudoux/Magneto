# PrintConstraint.jl
module PrintConstraint

using IntervalArithmetic
using DataStructure

# ----- EXPORT FUNCTIONS -----
export print_constant
export print_variable
export print_relative_error
export print_unary_operation
export print_biary_operation
export print_constraint
export print_variables_tbl

function print_rgb(r, g, b, t)
    print("\e[1m\e[38;2;$r;$g;$b;249m",t)
end

# ----- PRINT CONSTANT -----
function print_constant(c::DataConstant)
    message="Constant "*c.dataName*" ("*c.dataType*") = "
    print_rgb(51,153,255,message)
    print(c.dataValue)
    print_rgb(255,255,255,"\n")
end

function print_constants_tbl(c::Array{DataConstant})
    message="Constants \t"
    print_rgb(51,153,255,message)
    for i = 1:length(c)
        print(c[i].dataName," = ",c[i].dataValue,",  ")
    end
    print_rgb(255,255,255,"\n")
end


# ----- PRINT VARIABLE -----
function print_variable(v::DataVariable)
    message="Variable "*v.dataName*" ("*v.dataType*") = "
    print_rgb(147,112,219,message)
    print(v.dataValue)
    print_rgb(255,255,255,"\n")
end

function print_variables_tbl(c::Array{DataVariable})
    message="Variables \t"
    print_rgb(147,112,219,message)
    for i = 1:length(c)
        print(c[i].dataName," = ",c[i].dataValue,",  ")
    end
    print_rgb(255,255,255,"\n")
end


# ----- PRINT RELATIVE ERROR -----
function print_relative_error(eps::DataConstant)
    message="Relative Error = "
    print_rgb(0,204,204,message)
    print(eps.dataValue)
    print_rgb(255,255,255,"\n")
end

# ----- PRINT UNARY OPERATION -----
function print_unary_operation(uo::DataUnaryOperation)
    message="Unary Operator "*uo.dataSymbol*"(\n"
    print_rgb(119,136,153,message)

    print("\t")
    if (typeof(uo.dataOperand)==DataVariable)
        print_variable(uo.dataOperand)
    elseif (typeof(uo.dataOperand)==DataConstant) 
        print_constant(uo.dataOperand)
    elseif (typeof(uo.dataOperand)==DataUnaryOperation)
        print_unary_operation(uo.dataOperand)
    else
        print_binary_operation(uo.dataOperand)
    end
    
    print_rgb(119,136,153,")")
    print_rgb(255,255,255,"\n")    
end

# ----- PRINT BINARY OPERATION -----
function print_binary_operation(bo::DataBinaryOperation)
    message="Binary Operator "*bo.dataSymbol*"(\n"
    print_rgb(188,143,143,message)

    print("\tLEFT\t")
    if (typeof(bo.dataLeftOperand)==DataVariable)
        print_variable(bo.dataLeftOperand)
    elseif (typeof(bo.dataLeftOperand)==DataConstant) 
        print_constant(bo.dataLeftOperand)
    elseif (typeof(bo.dataLeftOperand)==DataUnaryOperation)
        print_unary_operation(bo.dataLeftOperand)
    else
        print_binary_operation(bo.dataLeftOperand)
    end

    print_rgb(188,143,143,"\tRIGHT\t")
    if (typeof(bo.dataRightOperand)==DataVariable)
        print_variable(bo.dataRightOperand)
    elseif (typeof(bo.dataRightOperand)==DataConstant) 
        print_constant(bo.dataRightOperand)
    elseif (typeof(bo.dataRightOperand)==DataUnaryOperation)
        print_unary_operation(bo.dataRightOperand)
    else
        print_binary_operation(bo.dataRightOperand)
    end
    
    print_rgb(188,143,143,")")
    print_rgb(255,255,255,"\n")

end

# ----- PRINT CONSTRAINT -----
function print_constraint(cst::DataConstraint)
    print_constants_tbl(cst.dataConstants)
    print_variables_tbl(cst.dataVariables)

    message="Constraint:\n"
    print_rgb(255,102,102,message)
    message="\tVariable "*cst.dataLeft.dataName*" ("*cst.dataLeft.dataType*") =" 
    print_rgb(147,112,219,message)
    print(cst.dataLeft.dataValue)
    message=" "*cst.dataSymbol*"\n\t"
    print_rgb(255,102,102,message)
    
    if (typeof(cst.dataRight)==DataVariable)
        print_variable(cst.dataRight)
    elseif (typeof(cst.dataRight)==DataConstant) 
        print_constant(cst.dataRight)
    elseif (typeof(cst.dataRight)==DataUnaryOperation)
        print_unary_operation(cst.dataRight)
    else
        print_binary_operation(cst.dataRight)
    end

    print("\t")
    print_relative_error(cst.dataRelativeError)
    print_rgb(255,255,255,"\n")
end

end
