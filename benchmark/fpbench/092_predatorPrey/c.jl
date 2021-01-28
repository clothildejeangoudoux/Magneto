# (FPCore
#  (x)
#  :name
#  "predatorPrey"
#  :cite
#  (darulova-kuncak-2014 solovyev-et-al-2015)
#  :fpbench-domain
#  science
#  :precision
#  binary64
#  :pre
#  (<= 1/10 x 3/10)
#  (let ((r 4) (K 111/100)) (/ (* (* r x) x) (+ 1 (* (/ x K) (/ x K))))))


using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(1/10, 3/10))
c1 = DataConstant("c1","int",1)
c2 = DataConstant("c2","int",4)
c3 = DataConstant("c3","int",111)
c4 = DataConstant("c4","int",100)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [c2, c3, c1, c4]

C = DataConstraint("C_predatorPrey",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("/",
                                       DataBinaryOperation("*",
                                                           DataBinaryOperation("*",
                                                                               c2,
                                                                               x1),
                                                           x1),
                                       DataBinaryOperation("+",
                                                           c1,
                                                           DataBinaryOperation("*",
                                                                               DataBinaryOperation("/",
                                                                                                   x1,
                                                                                                   DataBinaryOperation("/",c3,c4)),
                                                                               DataBinaryOperation("/",
                                                                                                   x1,
                                                                                                   DataBinaryOperation("/",c3,c4))))),
                   eps)

test(C, variables, constants, ARGS)
