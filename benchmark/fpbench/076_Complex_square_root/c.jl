# (FPCore
#  (re im)
#  :name
#  "Complex square root"
#  :cite
#  (herbie-2015)
#  (* 1/2 (sqrt (* 2 (+ (sqrt (+ (* re re) (* im im))) re)))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(0.1,100))
x2 = DataVariable("x2","real",@interval(10,20))
c1 = DataConstant("c1","int",1)
c2 = DataConstant("c2","int",2)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2]
constants = [c1, c2]

C = DataConstraint("C_Complex_square_root",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("*",
                                       DataBinaryOperation("/",c1,c2),
                                       DataUnaryOperation("sqrt", DataBinaryOperation("*",
                                                                                      c2,
                                                                                      DataBinaryOperation("+", DataUnaryOperation("sqrt", DataBinaryOperation("+", DataBinaryOperation("*", x1, x1), DataBinaryOperation("*", x2, x2))), x1)))),
                   eps)

test(C, variables, constants, ARGS)
