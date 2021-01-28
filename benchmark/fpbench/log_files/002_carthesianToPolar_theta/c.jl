# (FPCore
#  (x y)
#  :name
#  "carthesianToPolar, theta"
#  :pre
#  (and (<= 1 x 100) (<= 1 y 100))
#  :spec
#  (* (atan2 y x) (/ 180 PI))
#  (let ((pi 314159265359/100000000000) (radiant (atan (/ y x))))
#    (* radiant (/ 180 pi))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(1,100))
x2 = DataVariable("x2","real",@interval(1,100))
c1 = DataConstant("c1","int",180)
c2 = DataConstant("c2","real",314159265359/100000000000)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2]
constants = [c1,c2]

C = DataConstraint("C_carthesianToPolar_theta",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("*",
                                       DataUnaryOperation("atan",
                                                          DataBinaryOperation("/",
                                                                              x2,
                                                                              x1)),
                                       DataBinaryOperation("/",
                                                           c1,
                                                           c2)),
                   eps)

test(C, variables, constants, ARGS)
