# (FPCore
#  (x y)
#  :name
#  "sec4-example"
#  :cite
#  (solovyev-et-al-2015)
#  :precision
#  binary64
#  :pre
#  (and (<= 1001/1000 x 2) (<= 1001/1000 y 2))
#  (let ((t (* x y))) (/ (- t 1) (- (* t t) 1))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(1001/1000, 2))
x2 = DataVariable("x2","real",@interval(1001/1000, 2))
c0 = DataConstant("c0","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2]
constants = [c0]

C = DataConstraint("C_sec4_example",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",
                                       DataBinaryOperation("-",
                                                           DataBinaryOperation("*",x1,x2),
                                                           c0),
                                      DataBinaryOperation("-",
                                                          DataBinaryOperation("*",
                                                                              DataBinaryOperation("*",x1,x2),
                                                                              DataBinaryOperation("*",x1,x2)),
                                                          c0)),
                   eps)

test(C, variables, constants, ARGS)
