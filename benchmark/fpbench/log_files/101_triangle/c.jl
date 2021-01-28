# (FPCore
#  (a b c)
#  :name
#  "triangle"
#  :cite
#  (darulova-kuncak-2014)
#  :pre
#  (and (<= 9 a 9) (<= 471/100 b 489/100) (<= 471/100 c 489/100))
#  (let ((s (/ (+ (+ a b) c) 2))) (sqrt (* (* (* s (- s a)) (- s b)) (- s c)))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
a = DataVariable("a","real",@interval(9, 9))
b = DataVariable("b","real",@interval(471/100, 489/100))
c = DataVariable("c","real",@interval(471/100, 489/100))
c2= DataConstant("c2","int",2)
eps = DataConstant("eps","real",10^-10) 

variables = [y, a, b, c]
constants = [c2]

C = DataConstraint("C_triangle",
                   constants,
                   variables,
                   "=",
                   y,
                   DataUnaryOperation("sqrt",
                                      DataBinaryOperation("*",
                                                          DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("/", DataBinaryOperation("+", DataBinaryOperation("+", a, b), c), c2), DataBinaryOperation("-",  DataBinaryOperation("/", DataBinaryOperation("+", DataBinaryOperation("+", a, b), c), c2),a)), DataBinaryOperation("-", DataBinaryOperation("/", DataBinaryOperation("+", DataBinaryOperation("+", a, b), c), c2),b)), DataBinaryOperation("-",  DataBinaryOperation("/", DataBinaryOperation("+", DataBinaryOperation("+", a, b), c), c2),c))),
                   eps)

test(C, variables, constants, ARGS)
