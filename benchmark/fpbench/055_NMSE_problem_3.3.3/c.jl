# (FPCore
#  (x)
#  :name
#  "NMSE problem 3.3.3"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  :pre
#  (!= x 0 1 -1)
#  (+ (- (/ 1 (+ x 1)) (/ 2 x)) (/ 1 (- x 1))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(10,20))
c1 = DataConstant("c1","int",1)
c2 = DataConstant("c2","int",2)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1, c2]

C = DataConstraint("C_NMSE_problem_3.3.3",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+",
                                       DataBinaryOperation("-",
                                                           DataBinaryOperation("/",
                                                                               c1,
                                                                               DataBinaryOperation("+", x1, c1)),
                                                           DataBinaryOperation("/", c2, x1)),
                                       DataBinaryOperation("/", c1, DataBinaryOperation("-", x1, c1))),
                   eps)

test(C, variables, constants, ARGS)
