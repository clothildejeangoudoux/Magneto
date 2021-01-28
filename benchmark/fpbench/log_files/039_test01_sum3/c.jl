# (FPCore
#  (x0 x1 x2)
#  :name
#  "test01_sum3"
#  :precision
#  binary32
#  :pre
#  (and (< 1 x0 2) (< 1 x1 2) (< 1 x2 2))
#  (let ((p0 (- (+ x0 x1) x2)) (p1 (- (+ x1 x2) x0)) (p2 (- (+ x2 x0) x1)))
# (+ (+ p0 p1) p2)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x0 = DataVariable("x0","real",@interval(1, 2))
x1 = DataVariable("x1","real",@interval(1, 2))
x2 = DataVariable("x2","real",@interval(1, 2))
eps = DataConstant("eps","real",10^-10)

variables = [y, x0,x1, x2]
constants = []

C = DataConstraint("C_test01_sum3",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+",
                                       DataBinaryOperation("+",
                                                           DataBinaryOperation("-",
                                                                               DataBinaryOperation("+",
                                                                                                   x0,
                                                                                                   x1),
                                                                               x2),
                                                           DataBinaryOperation("-",
                                                                               DataBinaryOperation("+",
                                                                                                   x1,
                                                                                                   x2),
                                                                               x0)),
                                       DataBinaryOperation("-",
                                                           DataBinaryOperation("+",
                                                                               x2,
                                                                               x0),
                                                           x1)),
                   eps)

test(C, variables, constants, ARGS)
