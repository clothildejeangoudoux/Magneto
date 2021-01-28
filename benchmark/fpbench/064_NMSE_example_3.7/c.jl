# (FPCore
#  (x)
#  :name
#  "NMSE example 3.7"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  (- (exp x) 1))


using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(10,20))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1]

C = DataConstraint("C_NMSE_example_3.7",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataUnaryOperation("exp",
                                                          x1),
                                       c1),
                   eps)

test(C, variables, constants, ARGS)
