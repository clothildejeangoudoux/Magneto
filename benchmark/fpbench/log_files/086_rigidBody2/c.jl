# (FPCore
#  (x1 x2 x3)
#  :name
#  "rigidBody2"
#  :cite
#  (darulova-kuncak-2014 solovyev-et-al-2015)
#  :fpbench-domain
#  science
#  :precision
#  binary64
#  :pre
#  (and (<= -15 x1 15) (<= -15 x2 15) (<= -15 x3 15))
#  (-
#   (+
#    (- (+ (* (* (* 2 x1) x2) x3) (* (* 3 x3) x3)) (* (* (* x2 x1) x2) x3))
#    (* (* 3 x3) x3))
#   x2))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(-15, 15))
x2 = DataVariable("x2","real",@interval(-15, 15))
x3 = DataVariable("x3","real",@interval(-15, 15))
c0 = DataConstant("c0","int",2)
c1 = DataConstant("c1","int",3)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2, x3]
constants = [c0, c1]

C = DataConstraint("C_rigidBody2",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("+",
                                                           DataBinaryOperation("-", DataBinaryOperation("+", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", c0, x1), x2), x3), DataBinaryOperation("*", DataBinaryOperation("*", c1, x3), x3)), DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", x2, x1), x2), x3)),
                                                           DataBinaryOperation("*", DataBinaryOperation("*", c1, x3), x3)),
                                       x2),
                   eps)

test(C, variables, constants, ARGS)
