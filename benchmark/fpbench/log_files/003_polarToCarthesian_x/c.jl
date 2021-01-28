# (FPCore
#  (radius theta)
#  :name
#  "polarToCarthesian, x"
#  :pre
#  (and (<= 1 radius 10) (<= 0 theta 360))
#  :spec
#  (* radius (cos (* theta (/ 180 PI))))
#  (let* ((pi 314159265359/100000000000) (radiant (* theta (/ pi 180))))
#    (* radius (cos radiant))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
radius = DataVariable("radius","real",@interval(1,10))
theta = DataVariable("theta","real",@interval(0,360))
c1 = DataConstant("c1","int",180)
c2 = DataConstant("c2","real",314159265359/100000000000)
eps = DataConstant("eps","real",10^-10) 

variables = [y, radius, theta]
constants = [c1,c2]

C = DataConstraint("C_polarToCarthesian_x",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("*",
                                       radius,
                                       DataUnaryOperation("cos",
                                                          DataBinaryOperation("*",
                                                                              theta,
                                                                              DataBinaryOperation("/",
                                                                                                  c1,
                                                                                                  c2)))),
                   eps)

test(C, variables, constants, ARGS)
