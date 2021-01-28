# (FPCore
#  (m0 m1 m2 w0 w1 w2 a0 a1 a2)
#  :name
#  "test04_dqmom9"
#  :precision
#  binary64
#  :pre
#  (and (< -1 m0 1)
#       (< -1 m1 1)
#       (< -1 m2 1)
#       (< 1/100000 w0 1)
#       (< 1/100000 w1 1)
#       (< 1/100000 w2 1)
#       (< 1/100000 a0 1)
#       (< 1/100000 a1 1)
#       (< 1/100000 a2 1))
#  (let ((v2 (* (* w2 (- 0 m2)) (* -3 (* (* 1 (/ a2 w2)) (/ a2 w2)))))
#        (v1 (* (* w1 (- 0 m1)) (* -3 (* (* 1 (/ a1 w1)) (/ a1 w1)))))
#        (v0 (* (* w0 (- 0 m0)) (* -3 (* (* 1 (/ a0 w0)) (/ a0 w0))))))
#    (+ 0 (+ (* v0 1) (+ (* v1 1) (+ (* v2 1) 0))))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
m0 = DataVariable("m0","real",@interval(-1, 1))
m1 = DataVariable("m1","real",@interval(-1, 1))
m2 = DataVariable("m2","real",@interval(-1, 1))
w0 = DataVariable("w0","real",@interval(1/100000, 1))
w1 = DataVariable("w1","real",@interval(1/100000, 1))
w2 = DataVariable("w2","real",@interval(1/100000, 1))
a0 = DataVariable("a0","real",@interval(1/100000, 1))
a1 = DataVariable("a1","real",@interval(1/100000, 1))
a2 = DataVariable("a2","real",@interval(1/100000, 1))
c0 = DataConstant("c0","int",0)
c1 = DataConstant("c1","int",1)
c2 = DataConstant("c2","int",-3)
eps = DataConstant("eps","real",10^-10) 

variables = [y, m0, m1, m2, w0, w1, w2, a0, a1, a2]
constants = [c0, c1, c2]

C = DataConstraint("C_test04_qqmom9",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+", c0,DataBinaryOperation("+", DataBinaryOperation("*",
                                                                                            DataBinaryOperation("*",DataBinaryOperation("*", w0,DataBinaryOperation("-",c0, m0)), DataBinaryOperation("*",c2, DataBinaryOperation("*",DataBinaryOperation("*", c1, DataBinaryOperation("/",a0,w0)),DataBinaryOperation("/",a0,w0)))),
                                                                                            c1),
                                                                   DataBinaryOperation("+",DataBinaryOperation("*",
                                                                                                               DataBinaryOperation("*",DataBinaryOperation("*", w1,DataBinaryOperation("-",c0, m1)), DataBinaryOperation("*",c2, DataBinaryOperation("*",DataBinaryOperation("*", c1, DataBinaryOperation("/",a1,w1)),DataBinaryOperation("/",a1,w1)))),
                                                                                                               c1),
                                                                                        DataBinaryOperation("+",DataBinaryOperation("*",
                                                                                                                                    DataBinaryOperation("*",DataBinaryOperation("*", w2,DataBinaryOperation("-",c0, m2)), DataBinaryOperation("*",c2, DataBinaryOperation("*",DataBinaryOperation("*", c1, DataBinaryOperation("/",a2,w2)),DataBinaryOperation("/",a2,w2)))),
                                                                                                                                    c1), c0)))),
                   eps)

test(C, variables, constants, ARGS)
