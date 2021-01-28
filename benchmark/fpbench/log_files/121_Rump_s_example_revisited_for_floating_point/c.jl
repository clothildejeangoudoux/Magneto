# (FPCore
#  (a b)
#  :name
#  "Rump's example revisited for floating point"
#  :example
#  ((a 77617) (b 33096))
#  :cite
#  (rump-revisited-2002)
#  (let ((b2 (* b b)))
#    (let ((b4 (* b2 b2)))
#      (let ((b6 (* b4 b2)) (b8 (* b4 b4)) (a2 (* a a)))
#        (let ((firstexpr (- (- (* (* 11 a2) b2) (* 121 b4)) 2)))
#          (+
#           (+ (+ (* (- 1335/4 a2) b6) (* a2 firstexpr)) (* 11/2 b8))
#           (/ a (* 2 b))))))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
a = DataVariable("a","real",@interval(77616,77618 ))
b = DataVariable("b","real",@interval(33095,33097 ))
c1= DataConstant("c1","int",1335)
c2= DataConstant("c2","int",4)
c3= DataConstant("c3","int",6)
c4= DataConstant("c4","int",2)
c5= DataConstant("c5","int",11)
c6= DataConstant("c6","int",121)
c7= DataConstant("c7","int",8)
eps = DataConstant("eps","real",10^-10) 

variables = [y, a, b]
constants = [c1, c2, c3, c4,c5, c6, c7]

C = DataConstraint("C_Rump_s_example_from_C_program",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+",
                                       DataBinaryOperation("+", DataBinaryOperation("+", DataBinaryOperation("*", DataBinaryOperation("-", DataBinaryOperation("/",c1,c2),DataBinaryOperation("*", a, a)), DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", b, b), DataBinaryOperation("*", b, b)), DataBinaryOperation("*", b, b))), DataBinaryOperation("*", DataBinaryOperation("*", a, a), DataBinaryOperation("-", DataBinaryOperation("-", DataBinaryOperation("-", DataBinaryOperation("*", DataBinaryOperation("*", c5, DataBinaryOperation("*", a, a)), DataBinaryOperation("*", b, b)), DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", b, b), DataBinaryOperation("*", b, b)), DataBinaryOperation("*", b, b))), DataBinaryOperation("*", c6, DataBinaryOperation("*", DataBinaryOperation("*", b, b), DataBinaryOperation("*", b, b)))), c4))), DataBinaryOperation("*", DataBinaryOperation("/",c5,c4), DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("*", b, b), DataBinaryOperation("*", b, b)), DataBinaryOperation("*", DataBinaryOperation("*", b, b), DataBinaryOperation("*", b, b))))),
                                       DataBinaryOperation("/", a, DataBinaryOperation("*", c4, b))),
                   eps)

test(C, variables, constants, ARGS)
