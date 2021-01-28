# (FPCore
#  (x)
#  :name
#  "NMSE problem 3.4.1"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (!= x 0)
#  (/ (- 1 (cos x)) (* x x)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(10,30))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1]

C = DataConstraint("C_NMSE_problem_3.4.1",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",
                                       DataBinaryOperation("-",
                                                           c1,
                                                           DataUnaryOperation("cos",
                                                                              x1)),
                                       DataBinaryOperation("*",
                                                           x1,
                                                           x1)),
                   eps)

test(C, variables, constants, ARGS)
