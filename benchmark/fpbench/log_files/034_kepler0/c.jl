# (FPCore
#  (x1 x2 x3 x4 x5 x6)
#  :name
#  "kepler0"
#  :precision
#  binary64
#  :pre
#  (and (<= 4 x1 159/25)
#       (<= 4 x2 159/25)
#       (<= 4 x3 159/25)
#       (<= 4 x4 159/25)
#       (<= 4 x5 159/25)
#       (<= 4 x6 159/25))
#  (+
#   (- (- (+ (* x2 x5) (* x3 x6)) (* x2 x3)) (* x5 x6))
#   (* x1 (+ (+ (- (+ (+ (- x1) x2) x3) x4) x5) x6))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(4,159/25))
x2 = DataVariable("x2","real",@interval(4,159/25))
x3 = DataVariable("x3","real",@interval(4,159/25))
x4 = DataVariable("x4","real",@interval(4,159/25))
x5 = DataVariable("x5","real",@interval(4,159/25))
x6 = DataVariable("x6","real",@interval(4,159/25))
c0 = DataConstant("c0","int",0)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2, x3, x4, x5, x6]
constants = [c0]

C = DataConstraint("C_kepler0",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+",
                                       DataBinaryOperation("-",
                                                           DataBinaryOperation("-",
                                                                               DataBinaryOperation("+",
                                                                                                   DataBinaryOperation("*", x2, x5),
                                                                                                   DataBinaryOperation("*", x3, x6)),
                                                                               DataBinaryOperation("*", x2, x3)),
                                                           DataBinaryOperation("*", x5, x6)),
                                       DataBinaryOperation("*", x1,
                                                           DataBinaryOperation("+",
                                                                               DataBinaryOperation("+",
                                                                                                   DataBinaryOperation("-",
                                                                                                                       DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("-",c0, x1), x2), x3), x4), x5), x6))),
                   eps)

test(C, variables, constants, ARGS)
