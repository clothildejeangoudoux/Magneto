# (FPCore
#  (x)
#  :name
#  "NMSE problem 3.4.4"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (!= x 0)
#  (sqrt (/ (- (exp (* 2 x)) 1) (- (exp x) 1))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(0.1,100))
c1 = DataConstant("c1","int",1)
c2 = DataConstant("c2","int",2)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1, c2]

C = DataConstraint("C_NMSE_problem_3.4.4",
                   constants,
                   variables,
                   "=",
                   y,
                   DataUnaryOperation("sqrt",
                                      DataBinaryOperation("/",
                                                          DataBinaryOperation("-",
                                                                              DataUnaryOperation("exp",
                                                                                                  DataBinaryOperation("*",
                                                                                                                      c2,
                                                                                                                      x1)),
                                                                              c1),
                                                          DataBinaryOperation("-",
                                                                              DataUnaryOperation("exp", x1),
                                                                              c1))),
                   eps)

test(C, variables, constants, ARGS)
