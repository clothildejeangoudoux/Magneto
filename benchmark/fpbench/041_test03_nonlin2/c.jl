# (FPCore
#  (x y)
#  :name
#  "test03_nonlin2"
#  :precision
#  binary64
#  :pre
#  (and (< 0 x 1) (< -1 y -1/10))
#  (/ (+ x y) (- x y)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(1, 2))
x1 = DataVariable("x1","real",@interval(1, 2))
eps = DataConstant("eps","real",10^-10) 

variables = [y, x0,x1]
constants = []

C = DataConstraint("C_test03_nonlin2",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/", DataBinaryOperation("+", x0, x1),
                                       DataBinaryOperation("-", x0, x1)),
                   eps)

test(C, variables, constants, ARGS)
