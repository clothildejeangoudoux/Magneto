# (FPCore
#  (x)
#  :name
#  "sqroot"
#  :cite
#  (darulova-kuncak-2014 solovyev-et-al-2015)
#  :fpbench-domain
#  mathematics
#  :pre
#  (<= 0 x 1)
#  (-
#   (+ (- (+ 1 (* 1/2 x)) (* (* 1/8 x) x)) (* (* (* 1/16 x) x) x))
#   (* (* (* (* 5/128 x) x) x) x)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x = DataVariable("x","real",@interval(0, 1))
c1= DataConstant("c1","int",1)
c2= DataConstant("c2","int",2)
c3= DataConstant("c3","int",16)
c4= DataConstant("c4","int",128)
c5= DataConstant("c5","int",5)
c8= DataConstant("c8","int",8)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x]
constants = [c1, c2, c3, c4, c5, c8]

C = DataConstraint("C_sqroot",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("+", DataBinaryOperation("-", DataBinaryOperation("+", c1, DataBinaryOperation("*", DataBinaryOperation("/",c1,c2), x)), DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("/",c1,c8), x), x)), DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("/",c1,c3), x), x), x)),
                                       DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("/",c5,c4), x), x), x), x)),
                   eps)

test(C, variables, constants, ARGS)
