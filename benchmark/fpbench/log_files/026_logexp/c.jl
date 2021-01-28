# (FPCore
#  (x)
#  :name
#  "logexp"
#  :cite
#  (solovyev-et-al-2015)
#  :precision
#  binary64
#  :pre
#  (<= -8 x 8)
#  (let ((e (exp x))) (log (+ 1 e))))


using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(-8,8))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c1]

C = DataConstraint("C_logexp",
                   constants,
                   variables,
                   "=",
                   y,
                   DataUnaryOperation("log",
                                      DataBinaryOperation("+",
                                                          c1,
                                                          DataUnaryOperation("exp",
                                                                             x1))),
                   eps)

test(C, variables, constants, ARGS)
