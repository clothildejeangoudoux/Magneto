# (FPCore
#  (u v T)
#  :name
#  "doppler3"
#  :cite
#  (darulova-kuncak-2014)
#  :fpbench-domain
#  science
#  :precision
#  binary64
#  :pre
#  (and (<= -30 u 120) (<= 320 v 20300) (<= -50 T 30))
#  (let ((t1 (+ 1657/5 (* 3/5 T)))) (/ (* (- t1) v) (* (+ t1 u) (+ t1 u)))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
u = DataVariable("u","real",@interval(-30, 120))
v = DataVariable("v","real",@interval(320, 20300))
T = DataVariable("T","real",@interval(-50,30))
c0 = DataConstant("c0","int",5)
c1 = DataConstant("c1","int",1657)
c2 = DataConstant("c2","int",3)
c3 = DataConstant("c3","int",0)
eps = DataConstant("eps","real",10^-10) 

variables = [y, u,v, T]
constants = [c0, c1, c2, c3]

C = DataConstraint("C_doppler3",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/", DataBinaryOperation("*", DataBinaryOperation("-",
                                                                                         c3,
                                                                                         DataBinaryOperation("+", DataBinaryOperation("/", c1, c0), DataBinaryOperation("*", DataBinaryOperation("/", c2, c0), T))),
                                                                v), DataBinaryOperation("*", DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("/", c1, c0), DataBinaryOperation("*", DataBinaryOperation("/", c2, c0), T)), u), DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("/", c1, c0), DataBinaryOperation("*", DataBinaryOperation("/", c2, c0), T)), u))),
                   eps)

test(C, variables, constants, ARGS)
