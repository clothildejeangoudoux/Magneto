 # (FPCore
 # (x eps)
 # :name
 # "NMSE problem 3.3.5"
 # :cite
 # (hamming-1987 herbie-2015)
 # :fpbench-domain
 # textbook
# (- (cos (+ x eps)) (cos x)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(10,20))
x2 = DataVariable("x2","real",@interval(10,20))
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2]
constants = []

C = DataConstraint("C_NMSE_problem_3.3.5",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataUnaryOperation("cos",
                                                           DataBinaryOperation("+",
                                                                               x1,
                                                                               x2)),
                                       DataUnaryOperation("cos", x1)),
                   eps)

test(C, variables, constants, ARGS)
