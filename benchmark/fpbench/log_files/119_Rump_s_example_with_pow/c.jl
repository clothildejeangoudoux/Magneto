# (FPCore
#  (a b)
#  :name
#  "Rump's example, with pow"
#  :example
#  ((a 77617) (b 33096))
#  (+
#   (+
#    (+
#     (* 1335/4 (pow b 6))
#     (*
#      (pow a 2)
#      (- (- (- (* (* 11 (pow a 2)) (pow b 2)) (pow b 6)) (* 121 (pow b 4))) 2)))
#    (* 11/2 (pow b 8)))
#   (/ a (* 2 b))))


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

C = DataConstraint("C_Rump_s_example_with_pow",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+",
                                       DataBinaryOperation("+",
                                                           DataBinaryOperation("+",
                                                                               DataBinaryOperation("*", DataBinaryOperation("/",c1,c2),DataBinaryOperation("^", b, c3)),
                                                                               DataBinaryOperation("*",
                                                                                                   DataBinaryOperation("^", a,c4),
                                                                                                   DataBinaryOperation("-", DataBinaryOperation("-", DataBinaryOperation("-", DataBinaryOperation("*", DataBinaryOperation("*", c5, DataBinaryOperation("^", a, c4)), DataBinaryOperation("^", b, c4)), DataBinaryOperation("^", b, c3)), DataBinaryOperation("*", c6, DataBinaryOperation("^", b, c2))), c4))),
                                                           DataBinaryOperation("*", DataBinaryOperation("/",c5,c4), DataBinaryOperation("^",b, c7))),
                                       DataBinaryOperation("/", a, DataBinaryOperation("*", c4, b))),
                   
                   eps)

test(C, variables, constants, ARGS)
