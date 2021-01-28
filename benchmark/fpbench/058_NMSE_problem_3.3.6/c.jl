# (FPCore
#  (N)
#  :name
#  "NMSE problem 3.3.6"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (> N 0)
#  (- (log (+ N 1)) (log N)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(10,20))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1]

C = DataConstraint("C_NMSE_problem_3.3.6",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataUnaryOperation("log",
                                                           DataBinaryOperation("+",
                                                                               x1,
                                                                               c1)),
                                       DataUnaryOperation("log", x1)),
                   eps)

test(C, variables, constants, ARGS)
