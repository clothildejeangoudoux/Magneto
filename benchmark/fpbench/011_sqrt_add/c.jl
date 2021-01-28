# (FPCore
#  (x)
#  :name
#  "sqrt_add"
#  :description
#  "Generated by FPTaylor"
#  :precision
#  binary64
#  :pre
#  (<= 1 x 1000)
#  (/ 1 (+ (sqrt (+ x 1)) (sqrt x))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x = DataVariable("x","real",@interval(1,1000))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x]
constants = [c1]

C = DataConstraint("C_sqrt_add",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",
                                       c1,
                                       DataBinaryOperation("+",
                                                           DataUnaryOperation("sqrt",
                                                                              DataBinaryOperation("+",
                                                                                                  x,
                                                                                                  c1)),
                                                           DataUnaryOperation("sqrt",
                                                                              x))),
                   eps)

test(C, variables, constants, ARGS)
