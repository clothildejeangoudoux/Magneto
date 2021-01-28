# DataStrcuture.jl
module DataStructure

using IntervalArithmetic

# ----- EXPORT BOUNDS OF PARAMETERS -----
export _MIN_REL_ERR
export _NB_BOXES
export _TIME
export MAX_RAND_TEST
export PREC_MUT_ERR

# ----- EXPORT TYPES -----
export DataVariable
export DataConstant
export DataUnaryOperation
export DataBinaryOperation
export DataConstraint
export Data
export DataTestResult
export DataTest

# ----- EXPORT SYMBOLS -----
export dataConstantSymbols
export dataConstraintSymbols
export dataUnaryOperationSymbols
export dataBinaryOperationSymbols

# ----- DEFINE BOUNDS OF PARAMETERS -----
_MIN_REL_ERR = 8
_NB_BOXES = 10000000
_TIME = 100

MAX_RAND_TEST = 1
PREC_MUT_ERR = 10^-6

# ----- DEFINE TYPES -----
abstract type Data end

mutable struct DataVariable<:Data
    dataName
    dataType
    dataValue
end

mutable struct DataConstant<:Data
    dataName
    dataType
    dataValue
end

mutable struct DataTestResult<:Data
    dataName
    dataValid
    dataInvalid
end

mutable struct DataTest<:Data
    dataTestVariables
    dataTestResult::DataTestResult
end


mutable struct DataUnaryOperation<:Data
    dataSymbol
    dataOperand::Data
end

mutable struct DataBinaryOperation<:Data
    dataSymbol
    dataLeftOperand::Data
    dataRightOperand::Data
end

mutable struct DataConstraint
    dataName
    dataConstants::Array{DataConstant}
    dataVariables::Array{DataVariable}
    dataSymbol
    dataLeft::Data
    dataRight::Data
    dataRelativeError::DataConstant
end

# ----- DEFINE SYMBOLS -----
# (global variables)
global dataConstantSymbols = ["@pi","@pi_2","@inv_pi","@2_pi","@3_pi_2","@sqrt_2","@3_pi","@5_pi_2","@e","@4_pi","@7_pi_2","@log2"]
global dataConstraintSymbols = ["=",">=","<="]
global dataUnaryOperationSymbols = ["sqrt","log","exp","cos","sin","tan","acos","asin","atan","cosh","sinh","tanh","acosh","asinh","atanh"]
global dataBinaryOperationSymbols = ["+","-","*","/","^","min","max"]

end
