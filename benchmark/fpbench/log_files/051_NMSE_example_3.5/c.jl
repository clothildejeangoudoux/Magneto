# (FPCore
#  (N)
#  :name
#  "NMSE example 3.5"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  (- (atan (+ N 1)) (atan N)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(1,10))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x0]
constants = [c1]

C = DataConstraint("C_NMSE_example_3.5",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataUnaryOperation("atan",
                                                          DataBinaryOperation("+",x0,c1)),
                                       DataUnaryOperation("atan",x0)),
                   eps)

test(C, variables, constants, ARGS)
