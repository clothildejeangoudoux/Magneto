# (FPCore
#  (x eps)
#  :name
#  "NMSE example 3.3"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  (- (sin (+ x eps)) (sin x)))


using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(0,10))
x1 = DataVariable("x1","real",@interval(0,10))
eps = DataConstant("eps","real",10^-10) 

variables = [y, x0,x1]
constants = []

C = DataConstraint("C_NMSE_example_3.3",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataUnaryOperation("sin",DataBinaryOperation("+",x0,x1)),
                                       DataUnaryOperation("sin",x0)),
                   eps)

test(C, variables, constants, ARGS)
