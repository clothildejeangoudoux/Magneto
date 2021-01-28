# (FPCore
#  (x)
#  :name
#  "NMSE problem 3.3.1"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (!= x 0)
#  (- (/ 1 (+ x 1)) (/ 1 x)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(1,10))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x0]
constants = [c1]

C = DataConstraint("C_NMSE_problem_3.3.1",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("/",c1,
                                                           DataBinaryOperation("+",x0,c1)),
                                       DataBinaryOperation("/",c1,x0)),
                   eps)

test(C, variables, constants, ARGS)
