# (FPCore
#  (x)
#  :name
#  "test05_nonlin1, test2"
#  :precision
#  binary64
#  :pre
#  (< 100001/100000 x 2)
#  (/ 1 (+ x 1)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x = DataVariable("x","real",@interval(100001/100000, 2))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x]
constants = [c1]

C = DataConstraint("C_test05_nonlin1_test2",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",c1,
                                       DataBinaryOperation("+",c1,x)),
                   eps)

test(C, variables, constants, ARGS)
