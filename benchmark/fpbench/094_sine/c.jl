# (FPCore
#  (x)
#  :name
#  "sine"
#  :cite
#  (darulova-kuncak-2014 solovyev-et-al-2015)
#  :fpbench-domain
#  mathematics
#  :precision
#  binary64
#  :rosa-post
#  (=> res (< -1 res 1))
#  :rosa-ensuring
#  1/100000000000000
#  :pre
#  (< -157079632679/100000000000 x 157079632679/100000000000)
#  (-
#   (+ (- x (/ (* (* x x) x) 6)) (/ (* (* (* (* x x) x) x) x) 120))
#   (/ (* (* (* (* (* (* x x) x) x) x) x) x) 5040)))


using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(-157079632679/100000000000, 157079632679/100000000000))
c1= DataConstant("c1","int",6)
c2= DataConstant("c2","int",120)
c3= DataConstant("c3","int",5040)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1, c2, c3]

C = DataConstraint("C_sine",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("+", DataBinaryOperation("-", x1, DataBinaryOperation("/", DataBinaryOperation("*", DataBinaryOperation("*", x1, x1), x1), c1)), DataBinaryOperation("/", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", x1, x1), x1), x1), x1), c2)),
                                       DataBinaryOperation("/", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", x1, x1), x1), x1), x1), x1), x1), c3)),
                   eps)

test(C, variables, constants, ARGS)
