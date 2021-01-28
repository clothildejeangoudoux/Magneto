# (FPCore
#  (x)
#  :name
#  "NMSE example 3.10"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (< -1 x 1)
#  (/ (log (- 1 x)) (log (+ 1 x))))


using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(-1,1))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1]

C = DataConstraint("C_NMSE_example_3.10",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",
                                       DataUnaryOperation("log",
                                                          DataBinaryOperation("-",
                                                                              c1,
                                                                              x1)),
                                       DataUnaryOperation("log",
                                                          DataBinaryOperation("+",
                                                                              c1,
                                                                              x1))),
                   eps)

test(C, variables, constants, ARGS)
