# (FPCore
#  (x)
#  :name
#  "NMSE example 3.1"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (>= x 0)
#  (- (sqrt (+ x 1)) (sqrt x)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(0,+Inf))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x0]
constants = [c1]

C = DataConstraint("C_NMSE_example_3.1",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataUnaryOperation("sqrt",DataBinaryOperation("+",x0,c1)),
                                       DataUnaryOperation("sqrt",x0)),
                   eps)

test(C, variables, constants, ARGS)
