# (FPCore
#  (v)
#  :name
#  "carbonGas"
#  :cite
#  (darulova-kuncak-2014 solovyev-et-al-2015)
#  :fpbench-domain
#  science
#  :precision
#  binary64
#  :pre
#  (<= 1/10 v 1/2)
#  (let ((p 35000000)
#        (a 401/1000)
#        (b 427/10000000)
#        (t 300)
#        (n 1000)
#        (k 13806503/1000000000000000000000000000000))
#    (- (* (+ p (* (* a (/ n v)) (/ n v))) (- v (* n b))) (* (* k n) t))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x1 = DataVariable("x1","real",@interval(1/10, 1/2))
p= DataConstant("p","int",35000000)
a1=DataConstant("a1","int", 401)
a2=DataConstant("a2","int",1000)
b1=DataConstant("b1","int", 427)
b2=DataConstant("b2","int",10000000)
t=DataConstant("t","int", 300)
n=DataConstant("n","int", 1000)
k1=DataConstant("k1","int", 13806503)
k2=DataConstant("k2","int",1000000000000000000000000000000)
eps = DataConstant("eps","real",10^-10) 

variables = [y, x1]
constants = [p, a1, a2, b1, b2, t,n, k1, k2]

C = DataConstraint("C_carbonGas",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("-", DataBinaryOperation("*", DataBinaryOperation("+", p, DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("/",a1,a2), DataBinaryOperation("/", n, x1)), DataBinaryOperation("/", n, x1))), DataBinaryOperation("-", x1, DataBinaryOperation("*", n, DataBinaryOperation("/",b1,b2)))), DataBinaryOperation("*", DataBinaryOperation("*", DataBinaryOperation("/",k1,k2), n), t)),
                   eps)

test(C, variables, constants, ARGS)
