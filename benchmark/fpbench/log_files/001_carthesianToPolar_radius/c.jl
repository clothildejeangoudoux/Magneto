# (FPCore
#  (x y)
#  :name
#  "carthesianToPolar, radius"
#  :pre
#  (and (<= 1 x 100) (<= 1 y 100))
#  :spec
#  (hypot x y)
#  (sqrt (+ (* x x) (* y y))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(1,100))
x2 = DataVariable("x2","real",@interval(1,100))
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2]
constants = []

C = DataConstraint("C_carthesianToPolar_radius",
                   constants,
                   variables,
                   "=",
                   y,
                   DataUnaryOperation("sqrt",
                                      DataBinaryOperation("+",
                                                          DataBinaryOperation("*",
                                                                              x1,
                                                                              x1),
                                                          DataBinaryOperation("*",
                                                                              x2,
                                                                              x2))),
                   eps)

test(C, variables, constants, ARGS)

