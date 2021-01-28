# (FPCore
#  (u)
#  :name
#  "bspline3"
#  :cite
#  (darulova-kuncak-2014)
#  :pre
#  (<= 0 u 1)
#  :rosa-post
#  (=> res (<= -17/100 res 1/20))
#  :rosa-ensuring
#  1/100000000000
#  (/ (- (* (* u u) u)) 6))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x = DataVariable("x","real",@interval(0,1))
c1= DataConstant("c1","int",6)
c0= DataConstant("c0","int",0)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x]
constants = [c0,c1]

C = DataConstraint("C_bspline3",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/", DataBinaryOperation("-", c0, DataBinaryOperation("*", DataBinaryOperation("*", x, x), x)), c1),
                   eps)

test(C, variables, constants, ARGS)
