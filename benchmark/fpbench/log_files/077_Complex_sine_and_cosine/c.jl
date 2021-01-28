# (FPCore
#  (re im)
#  :name
#  "Complex sine and cosine"
#  :cite
#  (herbie-2015)
#  (* (* 1/2 (sin re)) (- (exp (- im)) (exp im))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(0.1,100))
x2 = DataVariable("x2","real",@interval(10,20))
c0 = DataConstant("c0","int",0)
c1 = DataConstant("c1","int",1)
c2 = DataConstant("c2","int",2)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2]
constants = [c0, c1, c2]

C = DataConstraint("C_Complex_sine_and_cosine",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("*", DataBinaryOperation("*",
                                                                DataBinaryOperation("/",c1,c2),
                                                                DataUnaryOperation("sin",
                                                                                   x1)),
                                       DataBinaryOperation("-",
                                                           DataUnaryOperation("exp",
                                                                              DataBinaryOperation("-",
                                                                                                  c0,
                                                                                                  x2)),
                                                           DataUnaryOperation("exp",x2))),
                   eps)

test(C, variables, constants, ARGS)
