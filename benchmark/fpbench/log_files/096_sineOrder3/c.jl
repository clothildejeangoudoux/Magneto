# (FPCore
#  (x)
#  :name
#  "sineOrder3"
#  :cite
#  (darulova-kuncak-2014 solovyev-et-al-2015)
#  :fpbench-domain
#  mathematics
#  :precision
#  binary64
#  :pre
#  (< -2 x 2)
#  :rosa-post
#  (=> res (< -1 res 1))
#  :rosa-ensuring
#  1/100000000000000
#  (-
#   (* 238732414637843/250000000000000 x)
#   (* 6450306886639899/50000000000000000 (* (* x x) x))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x = DataVariable("x","real",@interval(-2, 2))
c1= DataConstant("c1","int",238732414637843)
c2= DataConstant("c2","int",250000000000000)
c3= DataConstant("c3","int",6450306886639899)
c4= DataConstant("c4","int",50000000000000000)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x]
constants = [c1, c2, c3, c4]

C = DataConstraint("C_sineOrder3",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("*", DataBinaryOperation("/",c1,c2), x),
                                       DataBinaryOperation("*", DataBinaryOperation("/",c3,c4),
                                                           DataBinaryOperation("*", DataBinaryOperation("*", x, x), x))),
                   eps)

test(C, variables, constants, ARGS)
