# (FPCore
#  (x1 y1 x2 y2 x3 y3)
#  :name
#  "Shoelace formula"
#  :description
#  "Introduced in 'polygon-area'"
#  :precision
#  binary64
#  (let ((s1 (- (* x1 y2) (* y1 x2)))
#        (s2 (- (* x2 y3) (* y2 x3)))
#        (s3 (- (* x3 y1) (* y3 x1))))
#    (* 1/2 (+ (+ s1 s2) s3))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(0.1,100))
x2 = DataVariable("x2","real",@interval(10,20))
x3 = DataVariable("x3","real",@interval(10,20))
y1 = DataVariable("y1","real",@interval(0.1,100))
y2 = DataVariable("y2","real",@interval(10,20))
y3 = DataVariable("y3","real",@interval(10,20))
c1 = DataConstant("c1","int",1)
c2 = DataConstant("c2","int",2)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2,x3, y1, y2,y3]
constants = [c1, c2]

C = DataConstraint("C_Shoelace_formula",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("*", DataBinaryOperation("/",c1,
                                                                c2),
                                       DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("-", DataBinaryOperation("*", x1, y2), DataBinaryOperation("*", y1, x2)), DataBinaryOperation("-", DataBinaryOperation("*", x2, y3), DataBinaryOperation("*", y2, x3))), DataBinaryOperation("-", DataBinaryOperation("*", x2, y3), DataBinaryOperation("*", y2, x3)))),
                   eps)

test(C, variables, constants, ARGS)
