# (FPCore
#  (x)
#  :name
#  "NMSE example 3.4"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (!= x 0)
#  (/ (- 1 (cos x)) (sin x)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(1,10))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x0]
constants = [c1]

C = DataConstraint("C_NMSE_example_3.4",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",
                                       DataBinaryOperation("-",c1,DataUnaryOperation("cos",x0)),
                                       DataUnaryOperation("sin",x0)),
                   eps)

test(C, variables, constants, ARGS)
