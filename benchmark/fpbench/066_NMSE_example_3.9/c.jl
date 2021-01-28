# (FPCore
#  (x)
#  :name
#  "NMSE example 3.9"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (!= x 0)
#  (- (/ 1 x) (/ 1 (tan x))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(0.1,20))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1]

C = DataConstraint("C_NMSE_example_3.9",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("/",
                                                           c1,
                                                           x1),
                                       DataBinaryOperation("/",
                                                           c1,
                                                           DataUnaryOperation("tan",
                                                                              x1))),
                   eps)

test(C, variables, constants, ARGS)
