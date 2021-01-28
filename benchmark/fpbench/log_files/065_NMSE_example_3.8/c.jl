# (FPCore
#  (N)
#  :name
#  "NMSE example 3.8"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (> N 0)
#  (- (- (* (+ N 1) (log (+ N 1))) (* N (log N))) 1))


using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(0.1,20))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1]

C = DataConstraint("C_NMSE_example_3.8",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("-",
                                                           DataBinaryOperation("*",
                                                                               DataBinaryOperation("+",
                                                                                                   x1,
                                                                                                   c1),
                                                                               DataUnaryOperation("log",
                                                                                                  DataBinaryOperation("+",
                                                                                                                      x1,
                                                                                                                      c1))),
                                                           DataBinaryOperation("*",
                                                                               x1,
                                                                               DataUnaryOperation("log",
                                                                                                  x1))),
                                       c1),
                   eps)

test(C, variables, constants, ARGS)
