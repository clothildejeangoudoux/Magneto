# (FPCore
#  (x eps)
#  :name
#  "NMSE problem 3.3.2"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  (- (tan (+ x eps)) (tan x)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(1,10))
x1 = DataVariable("x1","real",@interval(1,10))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x0,x1]
constants = []

C = DataConstraint("C_NMSE_problem_3.3.2",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataUnaryOperation("tan", DataBinaryOperation("+",x0,x1)),
                                       DataUnaryOperation("tan",x0)),
                   eps)

test(C, variables, constants, ARGS)
