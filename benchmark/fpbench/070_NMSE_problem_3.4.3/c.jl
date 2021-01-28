# (FPCore
#  (eps)
#  :name
#  "NMSE problem 3.4.3"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (< -1 eps 1)
#  (log (/ (- 1 eps) (+ 1 eps))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(-1,1))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1]

C = DataConstraint("C_NMSE_problem_3.4.3",
                   constants,
                   variables,
                   "=",
                   y,
                   DataUnaryOperation("log",
                                      DataBinaryOperation("/", DataBinaryOperation("-", c1, x1),
                                                          DataBinaryOperation("+",
                                                                              c1,
                                                                              x1))),
                   eps)

test(C, variables, constants, ARGS)
