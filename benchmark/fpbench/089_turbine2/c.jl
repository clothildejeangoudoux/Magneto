# (FPCore
#  (v w r)
#  :name
#  "turbine2"
#  :cite
#  (darulova-kuncak-2014 solovyev-et-al-2015)
#  :fpbench-domain
#  controls
#  :precision
#  binary64
#  :pre
#  (and (<= -9/2 v -3/10) (<= 2/5 w 9/10) (<= 19/5 r 39/5))
#  (- (- (* 6 v) (/ (* (* 1/2 v) (* (* (* w w) r) r)) (- 1 v))) 5/2))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(-9/2, -3/10))
x2 = DataVariable("x2","real",@interval(2/5, 9/10))
x3 = DataVariable("x3","real",@interval(19/5, 39/5))
c1 = DataConstant("c1","int",1)
c2 = DataConstant("c2","int",2)
c3 = DataConstant("c3","int",5)
c4 = DataConstant("c4","int",6)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2, x3]
constants = [c2, c3, c1, c4]

C = DataConstraint("C_turbine2",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("-",
                                                           DataBinaryOperation("*", c4, x1),
                                                           DataBinaryOperation("/", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("/",c1,c2), x1), DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", x2, x2), x3), x3)), DataBinaryOperation("-", c1, x1))),
                                       DataBinaryOperation("/",c3,c2)),
                   eps)

test(C, variables, constants, ARGS)
