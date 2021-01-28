# (FPCore
#  (x1 x2 x3 x4)
#  :name
#  "kepler1"
#  :precision
#  binary64
#  :pre
#  (and (<= 4 x1 159/25) (<= 4 x2 159/25) (<= 4 x3 159/25) (<= 4 x4 159/25))
#  (-
#   (-
#    (-
#     (-
#      (+
#       (+
#        (* (* x1 x4) (- (+ (+ (- x1) x2) x3) x4))
#        (* x2 (+ (+ (- x1 x2) x3) x4)))
#       (* x3 (+ (- (+ x1 x2) x3) x4)))
#      (* (* x2 x3) x4))
#     (* x1 x3))
#    (* x1 x2))
#   x4))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(4,159/25))
x2 = DataVariable("x2","real",@interval(4,159/25))
x3 = DataVariable("x3","real",@interval(4,159/25))
x4 = DataVariable("x4","real",@interval(4,159/25))
c0 = DataConstant("c0","int",0)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2, x3, x4]
constants = [c0]

C = DataConstraint("C_kepler1",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("-",
                                                           DataBinaryOperation("-",
                                                                               DataBinaryOperation("-",
                                                                                                   DataBinaryOperation("+",
                                                                                                                       DataBinaryOperation("+",
                                                                                                                                           DataBinaryOperation("*", DataBinaryOperation("*", x1, x4), DataBinaryOperation("-", DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("-",c0, x1), x2), x3), x4)),
                                                                                                                                           DataBinaryOperation("*", x2, DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("-", x1, x2), x3), x4))),
                                                                                                                       DataBinaryOperation("*", x3, DataBinaryOperation("+", DataBinaryOperation("-", DataBinaryOperation("+", x1, x2), x3), x4))),
                                                                                                   DataBinaryOperation("*", DataBinaryOperation("*", x2, x3), x4)),
                                                                               DataBinaryOperation("*", x1, x3)),
                                                           DataBinaryOperation("*", x1, x2)),
                                       x4),
                   eps)

test(C, variables, constants, ARGS)
