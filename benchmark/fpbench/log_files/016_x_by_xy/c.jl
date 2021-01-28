# (FPCore
#  (x y)
#  :name
#  "x_by_xy"
#  :description
#  "Generated by FPTaylor"
#  :precision
#  binary32
#  :pre
#  (and (<= 1 x 4) (<= 1 y 4))
#  (/ x (+ x y)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(1,4))
x2 = DataVariable("x2","real",@interval(1,4))
eps = DataConstant("eps","real",10^-10)

variables = [y, x1, x2]
constants = []

C = DataConstraint("C_x_by_xy",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",
                                       x1,
                                       DataBinaryOperation("+",
                                                           x1,
                                                           x2)),
                   eps)

test(C, variables, constants, ARGS)