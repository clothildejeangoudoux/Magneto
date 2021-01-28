# (FPCore
#  (x)
#  :name
#  "NMSE problem 3.3.7"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  (+ (- (exp x) 2) (exp (- x))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(10,20))
c0 = DataConstant("c0","int",0)
c2 = DataConstant("c2","int",2)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c0,c2]

C = DataConstraint("C_NMSE_problem_3.3.6",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+",
                                       DataBinaryOperation("-",
                                                           DataUnaryOperation("exp",
                                                                              x1),
                                                           c2),
                                       DataUnaryOperation("exp",
                                                          DataBinaryOperation("-",
                                                                              c0,
                                                                              x1))),
                   eps)

test(C, variables, constants, ARGS)
