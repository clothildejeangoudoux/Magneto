# (FPCore
#  (a x)
#  :name
#  "NMSE section 3.5"
#  :cite
#  (hamming-1987 herbie-2015)
#  :fpbench-domain
#  textbook
#  (- (exp (* a x)) 1))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(0.1,100))
x2 = DataVariable("x2","real",@interval(10,20))
c1 = DataConstant("c1","int",1)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1, x2]
constants = [c1]

C = DataConstraint("C_NMSE_section_3.5",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-", DataUnaryOperation("exp",DataBinaryOperation("*",x1,x2)),c1),
                   eps)

test(C, variables, constants, ARGS)
