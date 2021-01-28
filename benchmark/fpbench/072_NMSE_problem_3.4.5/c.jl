# (FPCore
#  (x)
#  :name
#  "NMSE problem 3.4.5"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (!= x 0)
#  (/ (- x (sin x)) (- x (tan x))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(0.1,100))
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = []

C = DataConstraint("C_NMSE_problem_3.4.5",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/", DataBinaryOperation("-",
                                                                x1,
                                                                DataUnaryOperation("sin",
                                                                                    x1)),
                                       DataBinaryOperation("-", x1,
                                                           DataUnaryOperation("tan",
                                                                               x1))),
                   eps)

test(C, variables, constants, ARGS)
