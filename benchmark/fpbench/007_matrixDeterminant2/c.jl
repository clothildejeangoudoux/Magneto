# (FPCore
#  (a b c d e f g h i)
#  :name
#  "matrixDeterminant2"
#  :pre
#  (and (<= -10 a 10)
#       (<= -10 b 10)
#       (<= -10 c 10)
#       (<= -10 d 10)
#       (<= -10 e 10)
#       (<= -10 f 10)
#       (<= -10 g 10)
#       (<= -10 h 10)
#       (<= -10 i 10))
#  (-
#   (+ (* a (* e i)) (+ (* g (* b f)) (* c (* d h))))
#   (+ (* e (* c g)) (+ (* i (* b d)) (* a (* f h))))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
a = DataVariable("a","real",@interval(-10,10))
b = DataVariable("b","real",@interval(-10,10))
c = DataVariable("c","real",@interval(-10,10))
d = DataVariable("d","real",@interval(-10,10))
e = DataVariable("e","real",@interval(-10,10))
f = DataVariable("f","real",@interval(-10,10))
g = DataVariable("g","real",@interval(-10,10))
h = DataVariable("h","real",@interval(-10,10))
i = DataVariable("i","real",@interval(-10,10))
eps = DataConstant("eps","real",10^-10) 

variables = [y, a, b, c, d, e, f, g, h, i]
constants = []

C = DataConstraint("C_matrixDeterminant2",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-",
                                       DataBinaryOperation("+",
                                                           DataBinaryOperation("*",
                                                                               a,
                                                                               DataBinaryOperation("*",
                                                                                                   e,
                                                                                                   i)),
                                                           DataBinaryOperation("+",
                                                                               DataBinaryOperation("*",
                                                                                                   g,
                                                                                                   DataBinaryOperation("*",
                                                                                                                       b,
                                                                                                                       f)),
                                                                               DataBinaryOperation("*",
                                                                                                   c,
                                                                                                   DataBinaryOperation("*",
                                                                                                                       d,
                                                                                                                       h)))),
                                       DataBinaryOperation("+",
                                                           DataBinaryOperation("*",
                                                                               e,
                                                                               DataBinaryOperation("*",
                                                                                                   c,
                                                                                                   g)),
                                                           DataBinaryOperation("+",
                                                                               DataBinaryOperation("*",
                                                                                                   i,
                                                                                                   DataBinaryOperation("*",
                                                                                                                       b,
                                                                                                                       d)),
                                                                               DataBinaryOperation("*",
                                                                                                   a,
                                                                                                   DataBinaryOperation("*",
                                                                                                                       f,
                                                                                                                       h))))),
                   eps)

test(C, variables, constants, ARGS)
