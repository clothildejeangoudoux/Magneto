
# (FPCore
#  (x0 x1 x2 x3 x4 x5 x6 x7)
#  :name
#  "test02_sum8"
#  :precision
#  binary64
#  :pre
#  (and (< 1 x0 2)
#       (< 1 x1 2)
#       (< 1 x2 2)
#       (< 1 x3 2)
#       (< 1 x4 2)
#       (< 1 x5 2)
#       (< 1 x6 2)
#       (< 1 x7 2))
#  (+ (+ (+ (+ (+ (+ (+ x0 x1) x2) x3) x4) x5) x6) x7))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(1, 2))
x1 = DataVariable("x1","real",@interval(1, 2))
x2 = DataVariable("x2","real",@interval(1, 2))
x3 = DataVariable("x3","real",@interval(1, 2))
x4 = DataVariable("x4","real",@interval(1, 2))
x5 = DataVariable("x5","real",@interval(1, 2))
x6 = DataVariable("x6","real",@interval(1, 2))
x7 = DataVariable("x7","real",@interval(1, 2))
eps = DataConstant("eps","real",10^-10) 

variables = [y, x0,x1, x2, x3, x4, x5, x6, x7]
constants = []

C = DataConstraint("C_test02_sum8",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("+", x0, x1), x2), x3), x4), x5), x6), x7),
                   eps)

test(C, variables, constants, ARGS)
