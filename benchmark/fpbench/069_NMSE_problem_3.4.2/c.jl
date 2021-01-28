# (FPCore
#  (a b eps)
#  :name
#  "NMSE problem 3.4.2"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (!= eps 0)
#  (/
#   (* eps (- (exp (* (+ a b) eps)) 1))
#   (* (- (exp (* a eps)) 1) (- (exp (* b eps)) 1))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(10,30))
x2 = DataVariable("x2","real",@interval(10,20))
x3 = DataVariable("x3","real",@interval(10,20))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2,x3]
constants = [c1]

C = DataConstraint("C_NMSE_problem_3.4.2",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",
                                       DataBinaryOperation("*",
                                                           x3,
                                                           DataBinaryOperation("-",
                                                                               DataUnaryOperation("exp",
                                                                                                  DataBinaryOperation("*", DataBinaryOperation("+", x1, x2), x3)),
                                                                               c1)),
                                       DataBinaryOperation("*", DataBinaryOperation("-", DataUnaryOperation("exp", DataBinaryOperation("*", x1, x3)), c1),
                                                           DataBinaryOperation("-", DataUnaryOperation("exp", DataBinaryOperation("*", x2,x3)), c1))),
                   eps)

test(C, variables, constants, ARGS)
