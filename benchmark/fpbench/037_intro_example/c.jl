# (FPCore
#  (t)
#  :name
#  "intro-example"
#  :cite
#  (solovyev-et-al-2015)
#  :pre
#  (<= 0 t 999)
#  (/ t (+ t 1)))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
t = DataVariable("t","real",@interval(0,999))
c0 = DataConstant("c0","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, t]
constants = [c0]

C = DataConstraint("C_intro_example",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",
                                       t,
                                       DataBinaryOperation("+",t,c0)),
                   eps)

test(C, variables, constants, ARGS)
