# (FPCore
#  (x1 x2)
#  :name
#  "jetEngine"
#  :cite
#  (darulova-kuncak-2014 solovyev-et-al-2015)
#  :fpbench-domain
#  controls
#  :precision
#  binary64
#  :pre
#  (and (<= -5 x1 5) (<= -20 x2 5))
#  (let ((t (- (+ (* (* 3 x1) x1) (* 2 x2)) x1))
#        (t* (- (- (* (* 3 x1) x1) (* 2 x2)) x1))
#        (d (+ (* x1 x1) 1)))
#    (let ((s (/ t d)) (s* (/ t* d)))
#      (+
#       x1
#       (+
#        (+
#         (+
#          (+
#           (* (+ (* (* (* 2 x1) s) (- s 3)) (* (* x1 x1) (- (* 4 s) 6))) d)
#           (* (* (* 3 x1) x1) s))
#          (* (* x1 x1) x1))
#         x1)
#        (* 3 s*))))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(-15, 15))
x2 = DataVariable("x2","real",@interval(-15, 15))
c1 = DataConstant("c1","int",1)
c2 = DataConstant("c2","int",2)
c3 = DataConstant("c3","int",3)
c4 = DataConstant("c4","int",4)
c6 = DataConstant("c6","int",6)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2]
constants = [c2, c3, c1, c4, c6]

C = DataConstraint("C_jetEngine",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+",
                                       x1,
                                       DataBinaryOperation("+",
                                                           DataBinaryOperation("+",
                                                                               DataBinaryOperation("+",
                                                                                                   DataBinaryOperation("+",
                                                                                                                       DataBinaryOperation("*", DataBinaryOperation("+", DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", c2, x1), DataBinaryOperation("/", DataBinaryOperation("-", DataBinaryOperation("+", DataBinaryOperation("*", DataBinaryOperation("*", c3, x1), x1), DataBinaryOperation("*", c2, x2)), x1), DataBinaryOperation("+", DataBinaryOperation("*", x1, x1), c1))), DataBinaryOperation("-", DataBinaryOperation("/", DataBinaryOperation("-", DataBinaryOperation("+", DataBinaryOperation("*", DataBinaryOperation("*", c3, x1), x1), DataBinaryOperation("*", c2, x2)), x1), DataBinaryOperation("+", DataBinaryOperation("*", x1, x1), c1)), c3)), DataBinaryOperation("*", DataBinaryOperation("*", x1, x1), DataBinaryOperation("-", DataBinaryOperation("*", c4, DataBinaryOperation("/", DataBinaryOperation("-", DataBinaryOperation("+", DataBinaryOperation("*", DataBinaryOperation("*", c3, x1), x1), DataBinaryOperation("*", c2, x2)), x1), DataBinaryOperation("+", DataBinaryOperation("*", x1, x1), c1))), c6))), DataBinaryOperation("+", DataBinaryOperation("*", x1, x1), c1)),
                                                                                                                       DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", c3, x1), x1), DataBinaryOperation("/", DataBinaryOperation("-", DataBinaryOperation("+", DataBinaryOperation("*", DataBinaryOperation("*", c3, x1), x1), DataBinaryOperation("*", c2, x2)), x1), DataBinaryOperation("+", DataBinaryOperation("*", x1, x1), c1)))),
                                                                                                   DataBinaryOperation("*", DataBinaryOperation("*", x1, x1), x1)),
                                                                               x1),
                                                           DataBinaryOperation("*", c3, DataBinaryOperation("/", DataBinaryOperation("-", DataBinaryOperation("-", DataBinaryOperation("*", DataBinaryOperation("*", c3, x1), x1), DataBinaryOperation("*", c2, x2)), x1), DataBinaryOperation("+", DataBinaryOperation("*", x1, x1), c1))))),
                   eps)

test(C, variables, constants, ARGS)
