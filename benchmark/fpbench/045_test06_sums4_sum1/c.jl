# (FPCore
#  (x0 x1 x2 x3)
#  :name
#  "test06_sums4, sum1"
#  :precision
#  binary32
#  :pre
#  (and (< -1/100000 x0 100001/100000) (< 0 x1 1) (< 0 x2 1) (< 0 x3 1))
#  (+ (+ (+ x0 x1) x2) x3))


using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(-1/100000,100001/100000))
x1 = DataVariable("x1","real",@interval(0, 1))
x2 = DataVariable("x2","real",@interval(0, 1))
x3 = DataVariable("x3","real",@interval(0, 1))
eps = DataConstant("eps","real",10^-10)

variables = [y, x0, x1, x2, x3]
constants = []

C = DataConstraint("C_test06_sums4_sum1",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+",DataBinaryOperation("+",DataBinaryOperation("+",x0,x1),x2),x3),
                   eps)

test(C, variables, constants, ARGS)
